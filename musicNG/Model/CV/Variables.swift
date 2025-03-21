//
//  Variables.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import SwiftUI

extension EnvironmentValues {
//    @Entry var currentPlaylist = Playlist()
//    var currentSong: Binding<FileData?> {
//        get { self[CurrentSongKey.self] }
//        set { self[CurrentSongKey.self] = newValue }
//    }
}

//private struct CurrentSongKey: EnvironmentKey {
//    static let defaultValue: Binding<FileData?> = .constant(nil)
//}

class Downloads: ObservableObject {
    @Published var downloads: [DownloadData] = []
    var client = SMBClient()

    static var shared = Downloads()
    
    private init() {
        client.updateClient()
    }

    static func append(_ files: [FileData], listName: String) {
        for file in files {
            let newDowload = DownloadData()
            newDowload.file = file
            newDowload.listName = listName
            
            Downloads.shared.downloads.removeAll { $0.file.path == file.path }
            Downloads.shared.downloads.append(newDowload)
        }
    }
    
    static func startDownload() {
        if Downloads.shared.downloads.first(where: { $0.state == .downloading }) != nil {
            return
        }

        if let file = Downloads.shared.downloads.first(where: { $0.state == .idle }) {
            file.download()
        }
    }
    
    func stateUpdation() {
        DispatchQueue.main.async {
            Downloads.shared.downloads = Downloads.shared.downloads
        }
    }

}

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
        if all.isEmpty { return }
        
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
            if let cover = list.cover, let img = UIImage(data: cover)?.resizeImage(newSize: CGSize(width: 64, height: 64)), let data = img.jpegData(compressionQuality: 1) {
                try? data.write(to: currentDirPath.appendingPathComponent(list.name).appendingPathExtension("jpg"))
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

//Для информации что сейчас играет, определения обложки, пиков и т.д.
class Variables: ObservableObject {
    
    @Published var currentSong: FileData?

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

class OrientationCoordinator: ObservableObject {

    @Published var vertical: Bool = true
    var size: CGSize = CGSize(width: 0, height: 0)

    static var shared = OrientationCoordinator()
    
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

    @Published var current: Playlist? = nil

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
