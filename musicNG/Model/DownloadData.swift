//
//  DownloadData.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.01.2025.
//

import SwiftUI

class DownloadData: ObservableObject, Identifiable, Hashable {
    enum DowloadState: Int {
        case idle = 0
        case downloading = 1
        case downloaded = 2
        case error = 3
    }
    
    var id = UUID()
    @Published var file: FileData = FileData()
    @Published var state: DowloadState = .idle
    var error: String? = nil
    
    func download(listName: String, onDone: @escaping (() -> Void)) {
        state = .downloading
        onDone()
        
        DispatchQueue.global().async { [self] in
            file.getData { [self] data, error in
                if let error = error {
                    state = .error
                    self.error = error
                    
                    onDone()
                    
                    Downloads.startDownload(listName: listName)
                    return
                }
                
                if let data = data {
                    _ = FileManager.default.urlForPlaylistSettings(name: listName)
                    
                    file.path = "\(listName)/\(file.name)"
                    file.saveData(data: data, async: false)
                    
                    DispatchQueue.main.async { [self] in
                        state = .downloaded
                        
                        onDone()
                        
                        //TODO: - change to update current playlist only
                        Playlists.shared.reload()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            PlaylistCoordinator.shared.currentPlaylist = PlaylistCoordinator.shared.currentPlaylist
                        }
                        
                        Downloads.startDownload(listName: listName)
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        state = .error
                        self.error = "No data"

                        onDone()
                    }
                }
                
            }
        }
    }
    
    static func == (lhs: DownloadData, rhs: DownloadData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
