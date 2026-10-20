//
//  musicNGApp.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.10.2024.
//

import SwiftUI

@main
struct musicNGApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @State var playlistSelection: Bool = false
    @State var filePath: URL? = nil
    @State var playlistToSave: Playlist? = nil

    var body: some Scene {
        WindowGroup {
            MainView()
                .orientationChange(onChange: { size, vertical in
                    OrientationCoordinator.shared.size = size
                    OrientationCoordinator.shared.vertical = vertical
                })
                .onAppear {
                    FilesMetaDB.restore()
                    
                    if HTags.list.isEmpty {
                        HTags.restore()
                    }
                    
                    if !Settings.shared.isAppInitiated {
                        Playlists.shared.updateGlobalFiles()
                    }
                    
                    PlaybackCoordinator.shared.repeatMode = Settings.shared.repeatMode
                    PlaybackCoordinator.shared.shuffleMode = Settings.shared.shuffleMode
                }
                .onOpenURL { url in
                    if url.isFileURL {
                        filePath = url
                        withAnimation {
                            playlistSelection = true
                        }
                    }
                }
                .playListSelection(visible: $playlistSelection) { pl, isNew in
                    executePlaylistSelection(pl: pl, isNew: isNew)
                }
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            switch newScenePhase {
            case .inactive:
                if let curPos = MediaPlayer.shared.playerItem?.currentTime().seconds, !curPos.isNaN {
                    Settings.shared.lastSongPosition = curPos
                }
                FilesMetaDB.save()
            case .background:
                if let curPos = MediaPlayer.shared.playerItem?.currentTime().seconds, !curPos.isNaN {
                    Settings.shared.lastSongPosition = curPos
                }
                FilesMetaDB.save()
            case .active:
                try? FileManager.default.removeItem(at: FileManager.temp)

                FileData.getFilesFromShare()
            default: break
            }
        }
    }

    func executePlaylistSelection(pl: Playlist?, isNew: Bool) {
        guard let filePath = filePath, filePath.startAccessingSecurityScopedResource() else {
            playlistSelection = false
            return
        }
        
        defer {
            filePath.stopAccessingSecurityScopedResource()
        }
        
        let name = filePath.lastPathComponent
        
        var data: Data? = nil
        
        do {
            data = try Data(contentsOf: filePath)
        } catch {
            playlistSelection = false
            return
        }
        
        if isNew {
            let list = Playlist()
            list.name = name
            list.sortKey = Playlists.shared.all.count
            Playlists.shared.all.append(list)
            Playlists.shared.save()
            
            _ = FileManager.default.urlForPlaylistSettings(name: list.name)
            
            playlistToSave = list
        } else {
            playlistToSave = pl
        }
        
        let path = FileManager.default.urlForPlaylist(name: playlistToSave!.name).appending(component: name).path(percentEncoded: false)
        
        FileManager.default.createFile(atPath: path, contents: data)
        
        playlistToSave?.updateDownloads()
        
        playlistSelection = false
    }
}
