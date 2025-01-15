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
    @Published var state: DowloadState = .idle {
        didSet {
            Downloads.shared.stateUpdation()
        }
    }
    var error: String? = nil {
        didSet {
            state = .error
        }
    }
    var listName: String? = nil
    
    func download() {
        state = .downloading
        
        guard let listName = listName else {
            error = "List name is nil"
            Downloads.startDownload()
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            file.getData { [self] data, error in
                if let error = error {
                    self.error = error
                    
                    Downloads.startDownload()
                    return
                }
                
                if let data = data {
                    _ = FileManager.default.urlForPlaylistSettings(name: listName)
                    
                    file.path = "\(listName)/\(file.name)"
                    file.saveData(data: data, async: false)
                    
                    DispatchQueue.main.async { [self] in
                        state = .downloaded
                        
                        //TODO: - change to update current playlist only
                        Playlists.shared.reload()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            PlaylistCoordinator.shared.current = PlaylistCoordinator.shared.current
                        }
                        
                        Downloads.startDownload()
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        self.error = "No data"
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
