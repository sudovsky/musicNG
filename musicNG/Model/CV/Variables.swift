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

class Playlists: ObservableObject {

    @Published var all: [Playlist] = []

    static var shared = Playlists()
    
    private init() { }
    
    func reload(updatedResult: (([Playlist]) -> Void)? = nil) {
        _ = Playlist.getAll() { newLists in
            self.all = newLists
            updatedResult?(newLists)
        }
    }

    func save() {
        DispatchQueue.global().async {
            try? self.all.save(FileManager.playlistsSettings)

            self.updateGlobalFiles()
        }
    }
    
    func updateGlobalFiles() {
        let currentDirPath = FileManager.globalPlaylistsDir

        if FileManager.default.fileExists(atPath: currentDirPath.path) {
            try? FileManager.default.removeItem(at: currentDirPath)
            try? FileManager.default.createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }

        for list in all {
            if let cover = list.cover {
                try? cover.write(to: currentDirPath.appendingPathComponent(list.name).appendingPathExtension("jpg"))
            }
        }

        try? self.all.save(FileManager.globalPlaylistsSettingsFile)
    }

    func reloadView() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

class Variables: ObservableObject {
    @Published var currentSong: FileData?

    var currentPlaylist: Playlist? = nil
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

class PlaylistCoordinator: ObservableObject {

    @Published var currentPlaylist: Playlist? = nil

    static var shared = PlaylistCoordinator()
    
    private init() {}
    
}

class PlaylistSelectionCoordinator: ObservableObject {

    @Published var needShowSelection = false
    var playlistFromMove: Playlist? = nil
    var fileToMove: FileData? = nil

    static var shared = PlaylistSelectionCoordinator()
    
    private init() {}
    
}

class ViewUpdater: ObservableObject {
    func reloadView() {
        objectWillChange.send()
    }
}
