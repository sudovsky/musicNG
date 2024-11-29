//
//  Playlist.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import Foundation

class Playlist: Hashable, Codable, Identifiable {
    
    var id = UUID().uuidString
    var name = "Неизвестный"
    var date = Date()
    var songsSort: SortType = .userDefined
    
    var sortKey = 0
    
    var cover: Data? {
        if let url = urlForPlaylistCover() {
            return try? Data(contentsOf: url)
        } else {
            return nil
        }
    }
    
    func urlForPlaylistCover() -> URL? {
        let currentDirPath = FileManager.covers.appendingPathComponent(id).appendingPathExtension("jpg")

        if FileManager.default.fileExists(atPath: currentDirPath.path) {
            return currentDirPath
        }
        
        return nil
    }

    func updateCover() {
        DispatchQueue.global().async {
            
        }
    }
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
