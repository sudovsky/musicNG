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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .orientationChange(onChange: { size, vertical in
                    OrientationCoordinator.shared.size = size
                    OrientationCoordinator.shared.vertical = vertical
                })
                .onAppear {
                    if FilesMetaDB.data.isEmpty {
                        FilesMetaDB.restore()
                    }
                    
                    if !Settings.shared.isAppInitiated {
                        Playlists.shared.updateGlobalFiles()
                    }
                }
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .inactive:
                if let curPos = MediaPlayer.shared.playerItem?.currentTime().seconds, !curPos.isNaN {
                    Settings.shared.lastSongPosition = curPos
                }
                Settings.shared.save()
                FilesMetaDB.save()
            case .background:
                if let curPos = MediaPlayer.shared.playerItem?.currentTime().seconds, !curPos.isNaN {
                    Settings.shared.lastSongPosition = curPos
                }
                Settings.shared.save()
                FilesMetaDB.save()
            case .active:
                try? FileManager.default.removeItem(at: FileManager.temp)

                FileData.getFilesFromShare()
            default: break
            }
        }
    }
}
