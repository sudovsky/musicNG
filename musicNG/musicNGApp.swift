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
    
    @State private var needUpdatePL: Bool = false
    @State var firstRun = true
    
    var body: some Scene {
        WindowGroup {
            PlayListView(needUpdatePL: $needUpdatePL)
                .onAppear {
                    if FilesMetaDB.data.isEmpty {
                        FilesMetaDB.restore()
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
                if firstRun {
                    firstRun = false
                    return
                }
                
                needUpdatePL = true
            default: break
            }
        }
    }
}
