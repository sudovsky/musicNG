//
//  EqualizerView.swift
//  musicNG
//

import SwiftUI

/// Число полос в индикаторах по умолчанию (1...AudioSpectrumAnalyzer.resolution).
/// Для отдельного индикатора можно задать своё через параметр barCount.
let equalizerBarCount = 5

/// Квадратный индикатор из вертикальных полос. Ничего не настраивает — только показывает уровни.
struct EqualizerView: View {

    /// Уровни 0...1 в порядке отображения слева направо
    var levels: [Float]
    var color: Color = .white

    var body: some View {
        GeometryReader { geo in
            let count = max(levels.count, 1)
            // промежутки занимают ~30% ширины при любом числе полос
            let spacing = count > 1 ? geo.size.width * 0.3 / CGFloat(count - 1) : 0
            let barWidth = (geo.size.width - spacing * CGFloat(count - 1)) / CGFloat(count)

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(levels.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(color)
                        // минимальная высота — "точка", чтобы полоса не исчезала совсем
                        .frame(width: barWidth,
                               height: max(barWidth, geo.size.height * CGFloat(levels[i])))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(.linear(duration: 1.0 / 30), value: levels)
    }
}

/// Эквалайзер, подключённый к тому, что сейчас играет.
/// Полосы идут слева направо от НИЗКИХ частот к ВЫСОКИМ (highToLow = true — наоборот).
struct LiveEqualizerView: View {

    var barCount = equalizerBarCount
    var highToLow = false
    var color: Color = .white

    @ObservedObject private var analyzer = AudioSpectrumAnalyzer.shared
    @ObservedObject private var pb = PlaybackCoordinator.shared

    var body: some View {
        EqualizerView(levels: levels, color: color)
    }

    private var levels: [Float] {
        let count = min(max(barCount, 1), AudioSpectrumAnalyzer.resolution)
        
        // на паузе тап не вызывается — сами "роняем" полосы
        guard pb.isPlaying else {
            return [Float](repeating: 0, count: count)
        }
        
        let bars = Self.group(analyzer.spectrum, into: count)
        return highToLow ? bars.reversed() : bars
    }
    
    /// Сводит узкие полосы спектра в count широких: каждой достаётся равная
    /// доля (по логарифмической шкале частот), берётся самая громкая из узких.
    static func group(_ spectrum: [Float], into count: Int) -> [Float] {
        guard !spectrum.isEmpty else { return [Float](repeating: 0, count: count) }
        return (0..<count).map { bar in
            let start = bar * spectrum.count / count
            let end = max(start + 1, (bar + 1) * spectrum.count / count)
            return spectrum[start..<min(end, spectrum.count)].max() ?? 0
        }
    }
}

/// Индикатор для плитки: показывается, когда текущий трек — именно этот.
/// На паузе полосы опускаются до точек, но не исчезают.
/// Сам следит за текущей песней и состоянием плеера, поэтому плитке и списку
/// не нужно ничего пересчитывать при смене трека.
struct NowPlayingIndicator: View {

    enum Target {
        /// Трек с этим путём ("Плейлист/файл.mp3")
        case song(path: String)
        /// Плейлист, из которого играет текущий трек
        case playlist(name: String)
    }
    
    let target: Target
    var barCount = equalizerBarCount

    @ObservedObject private var variables = Variables.shared
    @ObservedObject private var pb = PlaybackCoordinator.shared

    private var isCurrent: Bool {
        guard let currentPath = variables.currentSong?.path else { return false }
        switch target {
        case .song(let path):
            return currentPath == path
        case .playlist(let name):
            // путь песни — "ИмяПлейлиста/имяФайла"
            return currentPath.hasPrefix(name + "/")
        }
    }

    var body: some View {
        if isCurrent {
            LiveEqualizerView(barCount: barCount)
                .shadow(color: .black.opacity(0.6), radius: 1)
                .transition(.opacity)
        }
    }
}

#Preview {
    EqualizerView(levels: [0.9, 0.6, 0.75, 0.4, 0.55, 0.2])
        .frame(width: 96, height: 96)
        .padding()
        .background(.black)
}
