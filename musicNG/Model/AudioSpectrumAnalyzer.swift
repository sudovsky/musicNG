//
//  AudioSpectrumAnalyzer.swift
//  musicNG
//

import AVFoundation
import Accelerate
import MediaToolbox
import SwiftUI

/// Анализ спектра того, что сейчас играет AVPlayer.
///
/// Подключается к AVPlayerItem через MTAudioProcessingTap — звук не меняет, только читает.
/// Считает БПФ (Accelerate / vDSP) и раскладывает громкость на `resolution` узких полос
/// с логарифмическим шагом. Индикаторы сами сводят их к нужному числу полос.
final class AudioSpectrumAnalyzer: ObservableObject {

    static let shared = AudioSpectrumAnalyzer()

    /// Сколько узких полос считает анализатор — верхний предел для числа полос в индикаторе.
    static let resolution = 32

    /// Уровни узких полос 0...1 от НИЗКИХ частот к ВЫСОКИМ (resolution значений).
    /// Обновляются на главном потоке примерно 30 раз в секунду.
    @Published private(set) var spectrum = [Float](repeating: 0, count: resolution)

    /// Диапазон частот в Гц
    private static let minFrequency: Float = 40
    private static let maxFrequency: Float = 16_000

    /// Границы полос (resolution + 1 значение), логарифмический шаг — как слышит ухо:
    /// каждой октаве достаётся примерно одинаковое число полос.
    private let bandEdges: [Float] = (0...resolution).map { i in
        minFrequency * pow(maxFrequency / minFrequency, Float(i) / Float(resolution))
    }

    /// Диапазон громкости (дБ), который растягивается на всю высоту полосы.
    /// Полосы всё время "в потолке" — увеличьте maxDB (ближе к 0) или curve;
    /// еле шевелятся — уменьшите maxDB или curve.
    private let minDB: Float = -50
    private let maxDB: Float = -0
    
    /// Нелинейность отклика: > 1 прижимает тихие и средние уровни вниз,
    /// так что до верха доходят только громкие пики и движение заметнее.
    private let curve: Float = 1.4
    
    /// Подъём высоких частот, дБ на октаву выше tiltReference. У музыки энергия падает
    /// с ростом частоты, и без подъёма хэты/тарелки почти не видны.
    /// Высокие всё ещё низко — увеличьте (4...6), слишком высоко — уменьшите.
    private let tiltDBPerOctave: Float = 5
    private let tiltReference: Float = 1_000

    private let fftSize = 1024
    private let fft: vDSP.FFT<DSPSplitComplex>
    private let window: [Float]

    // Всё ниже трогается только из аудиопотока тапа (под lock — на случай,
    // если при смене трека старый и новый тап на мгновение работают одновременно).
    private let lock = NSLock()
    private var sampleRate: Float = 44_100
    private var channels = 2
    private var isFloat = true
    private var isNonInterleaved = true
    private var samples: [Float] = []
    private var smoothed = [Float](repeating: 0, count: resolution)
    /// Максимум уровней по всем окнам с прошлой публикации — чтобы не терять короткие удары
    private var peakSinceUpdate = [Float](repeating: 0, count: resolution)
    private var lastUpdate: CFAbsoluteTime = 0
    private let updateInterval: CFAbsoluteTime = 1.0 / 30

    private init() {
        let log2n = vDSP_Length(log2(Float(fftSize)))
        fft = vDSP.FFT(log2n: log2n, radix: .radix2, ofType: DSPSplitComplex.self)!
        window = vDSP.window(ofType: Float.self, usingSequence: .hanningDenormalized, count: fftSize, isHalfWindow: false)
        samples.reserveCapacity(fftSize * 4)
    }

    // MARK: - Подключение к плееру

    /// Подключить анализ к новому элементу плеера. Вызывать при создании каждого AVPlayerItem.
    func attach(to item: AVPlayerItem) {
        reset()

        Task {
            guard let track = try? await item.asset.loadTracks(withMediaType: .audio).first,
                  let tap = makeTap() else { return }

            let params = AVMutableAudioMixInputParameters(track: track)
            params.audioTapProcessor = tap

            let mix = AVMutableAudioMix()
            mix.inputParameters = [params]

            await MainActor.run {
                item.audioMix = mix
            }
        }
    }

    /// Обнулить полосы (например, при смене трека).
    func reset() {
        DispatchQueue.main.async {
            self.spectrum = [Float](repeating: 0, count: Self.resolution)
        }
    }

    private func makeTap() -> MTAudioProcessingTap? {
        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: Unmanaged.passUnretained(self).toOpaque(),
            init: { _, clientInfo, tapStorageOut in
                // анализатор — синглтон, поэтому хранить неудерживающую ссылку безопасно
                tapStorageOut.pointee = clientInfo
            },
            finalize: nil,
            prepare: { tap, _, format in
                AudioSpectrumAnalyzer.from(tap).prepare(format: format.pointee)
            },
            unprepare: nil,
            process: { tap, numberFrames, _, bufferList, numberFramesOut, flagsOut in
                // Забираем исходный звук — без этого тап "заглушит" воспроизведение
                let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferList, flagsOut, nil, numberFramesOut)
                guard status == noErr else { return }
                AudioSpectrumAnalyzer.from(tap).process(bufferList: bufferList, frameCount: Int(numberFramesOut.pointee))
            }
        )

        var tap: MTAudioProcessingTap?
        let status = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
        return status == noErr ? tap : nil
    }

    private static func from(_ tap: MTAudioProcessingTap) -> AudioSpectrumAnalyzer {
        Unmanaged<AudioSpectrumAnalyzer>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
    }

    // MARK: - Аудиопоток

    private func prepare(format: AudioStreamBasicDescription) {
        lock.lock()
        defer { lock.unlock() }

        sampleRate = Float(format.mSampleRate)
        channels = max(Int(format.mChannelsPerFrame), 1)
        isFloat = format.mFormatFlags & kAudioFormatFlagIsFloat != 0
        isNonInterleaved = format.mFormatFlags & kAudioFormatFlagIsNonInterleaved != 0
        samples.removeAll(keepingCapacity: true)
        smoothed = [Float](repeating: 0, count: Self.resolution)
        peakSinceUpdate = [Float](repeating: 0, count: Self.resolution)
    }

    private func process(bufferList: UnsafeMutablePointer<AudioBufferList>, frameCount: Int) {
        guard frameCount > 0 else { return }

        lock.lock()
        defer { lock.unlock() }

        // Тап отдаёт Float32 в подавляющем большинстве случаев; иное просто пропускаем
        guard isFloat else { return }

        let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
        guard let data = buffers.first?.mData else { return }
        let ptr = data.assumingMemoryBound(to: Float.self)

        // Для визуализации достаточно одного (левого) канала
        if isNonInterleaved {
            samples.append(contentsOf: UnsafeBufferPointer(start: ptr, count: frameCount))
        } else {
            for i in 0..<frameCount {
                samples.append(ptr[i * channels])
            }
        }

        // Анализируем ВСЕ окна в пришедшем куске (с перекрытием в половину окна), а не только
        // последнее: тап отдаёт звук кусками по ~4096 сэмплов, и короткий удар хэта иначе
        // часто проскакивает между анализами. По каждой полосе запоминаем максимум.
        let hop = fftSize / 2
        while samples.count >= fftSize {
            let levels = computeBands(Array(samples.prefix(fftSize)))
            for i in 0..<Self.resolution {
                peakSinceUpdate[i] = max(peakSinceUpdate[i], levels[i])
            }
            samples.removeFirst(hop)
        }

        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastUpdate >= updateInterval else { return }
        lastUpdate = now

        for i in 0..<Self.resolution {
            // Быстро растём, медленно опадаем — так полосы выглядят "живо", но не дёргаются
            let level = peakSinceUpdate[i]
            let factor: Float = level > smoothed[i] ? 0.7 : 0.25
            smoothed[i] += (level - smoothed[i]) * factor
            peakSinceUpdate[i] = 0
        }

        let values = smoothed
        DispatchQueue.main.async {
            self.spectrum = values
        }
    }

    /// БПФ окна из fftSize сэмплов → уровни полос 0...1 (от низких к высоким)
    private func computeBands(_ frame: [Float]) -> [Float] {
        let half = fftSize / 2
        let windowed = vDSP.multiply(frame, window)

        var inReal = [Float](repeating: 0, count: half)
        var inImag = [Float](repeating: 0, count: half)
        var outReal = [Float](repeating: 0, count: half)
        var outImag = [Float](repeating: 0, count: half)
        var magnitudes = [Float](repeating: 0, count: half)

        inReal.withUnsafeMutableBufferPointer { inRealPtr in
            inImag.withUnsafeMutableBufferPointer { inImagPtr in
                outReal.withUnsafeMutableBufferPointer { outRealPtr in
                    outImag.withUnsafeMutableBufferPointer { outImagPtr in
                        var input = DSPSplitComplex(realp: inRealPtr.baseAddress!, imagp: inImagPtr.baseAddress!)
                        var output = DSPSplitComplex(realp: outRealPtr.baseAddress!, imagp: outImagPtr.baseAddress!)

                        // Вещественный сигнал упаковываем в комплексный вид, который ждёт vDSP
                        windowed.withUnsafeBufferPointer { windowedPtr in
                            windowedPtr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: half) {
                                vDSP_ctoz($0, 2, &input, 1, vDSP_Length(half))
                            }
                        }

                        fft.forward(input: input, output: &output)

                        magnitudes.withUnsafeMutableBufferPointer { magPtr in
                            vDSP_zvabs(&output, 1, magPtr.baseAddress!, 1, vDSP_Length(half))
                        }
                    }
                }
            }
        }

        // |X| → амплитуда (0...1 для полной шкалы) с учётом окна Ханна и масштаба vDSP
        let scale = 2 / Float(fftSize)
        let binWidth = sampleRate / Float(fftSize)

        var result = [Float](repeating: 0, count: Self.resolution)
        for band in 0..<Self.resolution {
            let lo = max(1, Int(bandEdges[band] / binWidth))
            let hi = min(half - 1, max(lo, Int(bandEdges[band + 1] / binWidth)))

            // Суммарная энергия полосы, а не самый громкий бин: у шумовых звуков (хэт,
            // тарелки) энергия размазана по многим бинам, и каждый по отдельности тихий.
            var power: Float = 0
            for bin in lo...hi {
                let a = magnitudes[bin] * scale
                power += a * a
            }

            // Подъём высоких: +tiltDBPerOctave на каждую октаву выше tiltReference
            let center = sqrt(bandEdges[band] * bandEdges[band + 1])
            let tilt = tiltDBPerOctave * max(0, log2(center / tiltReference))

            let db = 10 * log10(max(power, 1e-18)) + tilt
            let linear = min(max((db - minDB) / (maxDB - minDB), 0), 1)
            result[band] = pow(linear, curve)
        }

        return result
    }
}
