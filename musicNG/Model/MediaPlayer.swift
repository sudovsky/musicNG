//
//  MediaPlayer.swift
//  musicNG
//
//  Created by Max Sudovsky on 16.12.2024.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI

final class MediaPlayer {
    
    static let shared = MediaPlayer()
    
    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    var remoteCommandCenterSetted = false
    
    var playlist: [FileData] = []
    var originalPlaylist: [FileData] = []
    var currentFile: Int = -1
    var currentData: FileData? { currentFile > -1 ? playlist[currentFile] : nil }
    var currentPlaylistName: String? = nil

    var shuffled: MPShuffleType = MPShuffleType(rawValue: Settings.shared.shuffleMode) ?? .off
    var repeated: MPRepeatType = MPRepeatType(rawValue: Settings.shared.repeatMode) ?? .all
    
    static var nurl: URL? = nil
    
    var paused = true {
        willSet {
            DispatchQueue.main.async {
                PlaybackCoordinator.shared.isPlaying = !newValue
            }
            
            if !newValue {
                setupTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    var timer = Timer()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] tmr in
            guard let self = self else {
                tmr.invalidate()
                return
            }
            
            updateCurrentPos()
        })
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if repeated == .all {
            nextFile()
            return
        } else if repeated == .one {
            let nextFile = playlist[currentFile]
            play(file: nextFile)
            return
        } else if repeated == .off, currentFile < playlist.count - 1 {
            currentFile += 1
            let nextFile = playlist[currentFile]
            play(file: nextFile)
            withAnimation {
                Variables.shared.currentSong = nextFile
            }
            return
        }
        
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        info?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        paused = true
        seek(positionTime: 0)
    }
    
    func initPlayback(file: FileData) {
        originalPlaylist.removeAll()
        originalPlaylist.append(file)
        playlist = originalPlaylist

        currentFile = 0
        play(file: file)
    }
    
    func initPlayback(playlist: [FileData], index: Int = 0, playlistName: String? = nil) {
        currentPlaylistName = playlistName
        originalPlaylist = playlist
        self.playlist = originalPlaylist
        
        currentFile = index
        if currentFile < playlist.count {
            play(file: playlist[currentFile])
        }
        
        if shuffled == .items {
            shuffleList()
        }
    }
    
    func shuffleList() {
        let curFile = playlist[currentFile]

        playlist.shuffle()
        playlist.removeAll(where: {$0.path == curFile.path})
        playlist.insert(curFile, at: 0)
        currentFile = 0
    }
    
    func unshuffleList() {
        let curFile = playlist[currentFile]
        playlist = originalPlaylist
        currentFile = playlist.firstIndex(where: { $0.path == curFile.path }) ?? 0
    }

    //https://stackoverflow.com/questions/52451454/ios-12-lock-screen-controls-for-music-app
    
    func play(file: FileData) {
        MediaPlayer.nurl = nil
        paused = false
        player?.pause()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            file.getData { data, error in
                if file.fileDownloaded {
                    self.playerItem = AVPlayerItem(url: file.fileURL())
                    if file.slowPeaks == nil {
                        file.updatePeaks()
                    }
                } else {
                    guard let data = data else { return }
                    
                    let components = file.name.components(separatedBy: ".")
                    let nurl = FileManager.default.createTempFile(data: data, ext: components.last ?? "")
                    self.playerItem = AVPlayerItem(url: nurl)
                    
                    MediaPlayer.nurl = nurl
                    
                    if let pi = self.playerItem {
                        let rdata = MediaPlayer.dataFromPlayerItem(item: pi)
                        file.title = rdata.0
                        file.artist = rdata.1
                        file.cover = rdata.2
                        
                        if file.slowPeaks == nil {
                            file.updatePeaks()
                        }
                    }
                }
                self.player = AVPlayer(playerItem: MediaPlayer.shared.playerItem)
                
                self.setupAudioSession()
                self.player?.play()
                self.setupNowPlaying(playerItem: self.playerItem!, file: file)
                self.setupRemoteCommandCenter()
                MPNowPlayingInfoCenter.default().playbackState = .playing
                
                NotificationCenter.default.post(name: NSNotification.Name("needUpdateNextSong"), object: nil, userInfo: ["path": file.path])
                
                //csView.isHidden = false
                //csView.show(file: file, coloredShadow: false)

            }
        }
    }
    
    func pause() {
        paused = true
        
        DispatchQueue.global().async {
            self.player?.pause()
            
            var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
            info?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playerItem?.currentTime().seconds
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
            
            MPNowPlayingInfoCenter.default().playbackState = .paused
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Error setting the AVAudioSession:", error.localizedDescription)
            }
        }
    }
    
    func unpause() {
        paused = false

        DispatchQueue.global().async {
            self.player?.play()
            
            do {
                try AVAudioSession.sharedInstance().setActive(false)
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Error setting the AVAudioSession:", error.localizedDescription)
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.player!.rate
            MPNowPlayingInfoCenter.default().playbackState = .playing
        }
    }
    
    func nextFile() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        
        if currentFile < playlist.count - 1 {
            currentFile += 1
            let nextFile = playlist[currentFile]
            withAnimation {
                Variables.shared.currentSong = nextFile
                PositionCoordinator.shared.position = 0
            }
            play(file: nextFile)
        } else if playlist.count > 0{
            currentFile = 0
            let nextFile = playlist[currentFile]
            withAnimation {
                Variables.shared.currentSong = nextFile
                PositionCoordinator.shared.position = 0
            }
            play(file: nextFile)
        }
    }
    
    func prevFile() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        
        if currentFile > 0, playlist.count > 0 {
            currentFile -= 1
            let nextFile = playlist[currentFile]
            withAnimation {
                Variables.shared.currentSong = nextFile
                PositionCoordinator.shared.position = 0
            }
            play(file: nextFile)
        } else if playlist.count > 0{
            currentFile = playlist.count - 1
            let nextFile = playlist[currentFile]
            withAnimation {
                Variables.shared.currentSong = nextFile
                PositionCoordinator.shared.position = 0
            }
            play(file: nextFile)
        }
    }
    
    func seek(positionTime: TimeInterval) {
        self.player?.seek(to: CMTime(seconds: positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [weak self] success in
            guard let self = self else {return}
            let playerRate = self.player!.rate
            if success {
                self.player?.rate = playerRate
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playerItem!.currentTime().seconds
            }
        })
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting the AVAudioSession:", error.localizedDescription)
        }
    }
    
    static func dataFromFile(file: FileData, updateDB: Bool, local: Bool = false, completion: @escaping (String?, String?, Data?, [Float]?) -> Void = { _,_,_,_ in }){
        
        if let fdbl = FilesMetaDB.getDataForPath(file.path) {
            completion(fdbl.title, fdbl.artist, fdbl.cover, fdbl.peaks)
            return
        }
        
        file.getData { data, error in
            let components = file.name.components(separatedBy: ".")
            let url = local ? file.fileURL() : FileManager.default.createTempFile(data: data!, ext: components.last ?? "")
            let pi = AVPlayerItem(url: url)
            let data = dataFromPlayerItem(item: pi)
            
            if !local { FileManager.default.deleteTempFile(url: url) }
            
            if updateDB {
                FilesMetaDB.appendData(path: file.path, title: data.0 ?? file.name, artist: data.1 ?? "Unknown", cover: data.2)
            }
            
            completion(data.0, data.1, data.2, nil)
        }
    }
    
    static func dataFromPlayerItem(item: AVPlayerItem) -> (String?, String?, Data?) {
        var title: String? = nil
        var artist: String? = nil
        var cover: Data? = nil
        
        if let metadataList = item.asset.metadata as? [AVMetadataItem] {
            for item in metadataList {
                
                guard let key = item.commonKey?.rawValue, let value = item.value else{
                    continue
                }
                
                switch key {
                case "title" : title = value as? String
                case "artist": artist = value as? String
                case "artwork" where value is Data:
                    if let value = value as? Data {
                        cover = value
                    }
                default:
                    continue
                }
            }
        }
        
        if let newTitle = title?.cString(using: .windowsCP1252), let tt = String.init(cString: newTitle, encoding: .windowsCP1251) {
            title = tt
        }
        
        if let newTitle = artist?.cString(using: .windowsCP1252), let tt = String.init(cString: newTitle, encoding: .windowsCP1251) {
            artist = tt
        }
        
        return (title, artist, cover)
    }
    
    func setupNowPlaying(playerItem: AVPlayerItem, file: FileData? = nil) {
        var title = file?.name ?? "Unknown track"
        var artist = "Unknown artist"
        var cover: UIImage? = nil
        
        if let item = self.playerItem {
            let metadata = MediaPlayer.dataFromPlayerItem(item: item)
            title = metadata.0 ?? (file?.name ?? "Unknown track")
            artist = metadata.1 ?? "Unknown artist"
            if let metaCover = metadata.2 {
                cover = UIImage(data: metaCover) ?? UIImage(resource: .no)
            } else {
                cover = UIImage(resource: .no)
            }
        }
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        if let cover = cover {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { size in
                return cover
            })
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player!.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        //MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func switchRepeat() -> MPRepeatType {
        switch repeated {
        case .off: repeated = .all
        case .all: repeated = .one
        case .one: repeated = .off
        @unknown default:
            break
        }
        
        Settings.shared.repeatMode = repeated.rawValue
        
        MPRemoteCommandCenter.shared().changeRepeatModeCommand.currentRepeatType = repeated
        
        NotificationCenter.default.post(name: NSNotification.Name("MPRepeatShuffleStateChanged"), object: nil, userInfo: nil)
        
        return repeated
    }
    
    func switchShuffle() -> MPShuffleType {
        switch shuffled {
        case .collections: shuffled = .items
        case .items: shuffled = .off
        case .off: shuffled = .items
        @unknown default:
            break
        }
        
        if shuffled == .items {
            shuffleList()
        } else {
            unshuffleList()
        }
        
        Settings.shared.shuffleMode = shuffled.rawValue
        
        MPRemoteCommandCenter.shared().changeShuffleModeCommand.currentShuffleType = shuffled
        
        NotificationCenter.default.post(name: NSNotification.Name("MPRepeatShuffleStateChanged"), object: nil, userInfo: nil)
        
        return shuffled
    }
    
    func setupRemoteCommandCenter() {
        if remoteCommandCenterSetted {
            return
        }
        
        remoteCommandCenterSetted = true
        
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.unpause()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            self.nextFile()
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            self.prevFile()
            return .success
        }
        
        commandCenter.changeShuffleModeCommand.currentShuffleType = shuffled
        commandCenter.changeShuffleModeCommand.isEnabled = true
        commandCenter.changeShuffleModeCommand.addTarget { event in
            _ = self.switchShuffle()
            return .success
        }
        
        commandCenter.changeRepeatModeCommand.currentRepeatType = repeated
        commandCenter.changeRepeatModeCommand.isEnabled = true
        commandCenter.changeRepeatModeCommand.addTarget { event in
            _ = self.switchRepeat()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.seek(positionTime: event.positionTime)
                return .success
            } else {
                return .success
            }
        }
        
    }
    
    //https://github.com/bhavnishkumar/WaveAudioGenerator/blob/master/MusicWaveDemo/WaveGenerator.swift
    func readBuffer(_ audioUrl: URL, notify: Bool = true, completion: @escaping ([Float]) -> Void = {_ in})  {
        
        var currentPath = ""
        
        if notify {
            guard let cp = currentData?.path else {
                completion([])
                return
            }
            
            currentPath = cp
        }
        
        DispatchQueue.global().async {
            guard let file = try? AVAudioFile(forReading: MediaPlayer.nurl ?? audioUrl) else {
                completion([])
                return
            }
            
            let audioFormat = file.processingFormat
            let audioFrameCount = UInt32(file.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            else {
                completion([])
                return
            }
            do {
                try file.read(into: buffer)
            } catch {
                print(error)
            }
            
            let floatArray = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))

            var slowResult = [Float]()
            var peakCount: Int = 0
            DispatchQueue.main.sync {
                peakCount = PeaksView.peakCount()
            }

            var index = 0

            if floatArray.count == 0 {
                slowResult = []
            } else {
                let dif = (floatArray.count) / peakCount
                var sred: Float = 0
                var sredIndex: Int = 0
                for i in 0..<floatArray.count-1 {
                    if i > 0, CGFloat(i)/CGFloat(dif) == (CGFloat(i)/CGFloat(dif)).rounded() {
                        index += 1
                        if index > peakCount {
                            break
                        }
                        
                        //print("\(index)-\(i): \(samples[i])")
                        //result.append(floatArray[i])
                        slowResult.append(sred / Float(sredIndex))
                        sred = 0
                        sredIndex = 0
                    } else {
                        sredIndex += 1
                        sred += abs(floatArray[i])
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(slowResult)
                if notify {
                    NotificationCenter.default.post(name: NSNotification.Name("peaksDone"), object: nil, userInfo: ["path": currentPath, "peaks": slowResult, "fast": false])
                }
            }
        }
    }
    
    func updateCurrentPos() {
        guard let allSeconds = MediaPlayer.shared.playerItem?.duration.seconds,
              !allSeconds.isNaN,
              let curPos = MediaPlayer.shared.playerItem?.currentTime().seconds,
              !curPos.isNaN else {
            return
        }
        
        let step = PeaksView.width() / (allSeconds == 0 ? 1 : allSeconds)
        let curStep = step * curPos// + step / 2
        
        withAnimation(.linear) {
            PositionCoordinator.shared.position = curStep
        }
        
        PositionCoordinator.shared.curTime = getTimeFromSeconds(MediaPlayer.shared.playerItem?.currentTime().seconds ?? 0)
        PositionCoordinator.shared.endTime = getTimeFromSeconds(MediaPlayer.shared.playerItem?.duration.seconds ?? 0)
    }
    
    func getTimeFromSeconds(_ seconds: Double) -> String {
        if seconds.isNaN { return "0:00" }
        
        let rSeconds = seconds.rounded(.down)
        
        let min = rSeconds >= 60 ? (rSeconds / 60).rounded(.down) : 0
        let sec = (rSeconds - (min * 60)).rounded(.down)
        return "\(Int(min)):\(sec < 10 ? "0" : "")\(Int(sec))"
    }
    

}
