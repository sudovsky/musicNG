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
            if let data = try? Data(contentsOf: url) {
                return data
            } else {
                return nil
            }
        } else {
            return nil
            //return FileData.getDownloadsExt(for: self, readMetadata: true).first(where: { $0.cover != nil })?.cover
        }
    }
    
    func urlForPlaylistCover() -> URL? {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDirPath = documentsUrl.appendingPathComponent("Covers").appendingPathComponent(id).appendingPathExtension("jpg")

        if FileManager.default.fileExists(atPath: currentDirPath.path) {
            return currentDirPath
        }
        
        return nil
    }

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
