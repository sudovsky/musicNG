//
//  Variables.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import SwiftUICore

extension EnvironmentValues {
    @Entry var currentPlaylist = Playlist()
//    var currentSong: Binding<FileData?> {
//        get { self[CurrentSongKey.self] }
//        set { self[CurrentSongKey.self] = newValue }
//    }
}

//private struct CurrentSongKey: EnvironmentKey {
//    static let defaultValue: Binding<FileData?> = .constant(nil)
//}


class Variables: ObservableObject {
    @Published var currentSong: FileData?

    var currentPlaylist = Playlist()
    var songList: [FileData] = []

    static var shared = Variables()
    
    private init() {}
}

class PositionCoordinator: ObservableObject {

    @Published var position: CGFloat = 0
    @Published var curTime: String = "0:00"
    @Published var endTime: String = "0:00"

    static var shared = PositionCoordinator()
    
    private init() {}

    
}

class PlaybackCoordinator: ObservableObject {

    @Published var isPlaying = false
    @Published var repeatMode: Int = 0
    @Published var shuffleMode: Int = 0

    static var shared = PlaybackCoordinator()
    
    private init() {}
    
}
