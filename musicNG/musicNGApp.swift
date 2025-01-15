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
                .onAppear {
                    if FilesMetaDB.data.isEmpty {
                        FilesMetaDB.restore()
                    }
                    
                    if !Settings.shared.initiated {
                        Settings.shared.initiated = true
                        Settings.shared.save()
                        
                        Playlists.shared.updateGlobalFiles()
                    }
                }
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .inactive:
                Settings.shared.save()
                FilesMetaDB.save()
            case .background:
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
