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
    @Published var isPlaying = true

    var currentPlaylist = Playlist()
    var songList: [FileData] = []

    static var shared = Variables()
    
    private init() {}
}
