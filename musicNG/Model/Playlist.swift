//
//  Playlist.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import Foundation
import UIKit

class Playlist: Codable, Identifiable {
    
    var id = UUID().uuidString
    var name = "Пиздец Какой Неизвестный"
    var date = Date()
    var songsSort: SortType = .userDefined
    
    var customSortKey = 0
    
    var cover: UIImage? {
        if let url = urlForPlaylistCover() {
            return UIImage(contentsOfFile: url.path)
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

}
