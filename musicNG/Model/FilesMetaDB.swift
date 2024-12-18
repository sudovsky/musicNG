//
//  FilesMetaDB.swift
//  musicNG
//
//  Created by Max Sudovsky on 13.12.2024.
//

import SwiftUI

class FilesMetaDB {

    static var data = [FilesMetaDBLine]()
    
    static func restore() {
        data = load(FileManager.metaDB) ?? []
    }
    
    static func save() {
        try? data.save(FileManager.metaDB)
    }
    
    static func getDataForPath(_ path: String) -> FilesMetaDBLine? {
        if let fd = data.first(where: {$0.path == path}) {
            return fd
        }
        
        return nil
    }
    
    static func appendData(dataLine: FilesMetaDBLine) {
        data.append(dataLine)
    }
    
    static func appendData(path: String, title: String, artist: String, cover: Data? = nil, peaks: [Float]? = nil) {
        if FilesMetaDB.data.contains(where: { $0.path == path }) { return }
        
        let fdbl = FilesMetaDBLine()
        fdbl.path = path
        fdbl.title = title
        fdbl.artist = artist
        fdbl.peaks = peaks
        fdbl.saveCover(image: cover)
        
        data.append(fdbl)

    }
    
    static func removeData(path: String) {
        if let fd = data.first(where: {$0.path == path}) {
            fd.removeCover()
        }
        data.removeAll(where: {$0.path == path})
    }
    
    static func updatePeaks(path: String, peaks: [Float]) {
        if let fd = data.first(where: {$0.path == path}) {
            fd.peaks = peaks
        }
    }
    
    static func removePeaks(path: String) {
        if let fd = data.first(where: {$0.path == path}) {
            fd.peaks = nil
        }
    }
    
    static func clearCovers() {
//        let files = data.map { $0.id }
//        let playlistCovers = FileData.playlists.compactMap{ $0.urlForPlaylistCover() != nil ? $0.id : nil }
//        let covers = getallCovers()
//        for cover in covers {
//            let sname = cover.deletingPathExtension().lastPathComponent
//            if files.firstIndex(where: { $0 == sname }) == nil, playlistCovers.firstIndex(where: { $0 == sname }) == nil {
//                try? FileManager.default.removeItem(at: cover)
//            }
//        }
    }
    
    private static func getallCovers() -> [URL] {
        if let files = try? FileManager.default.contentsOfDirectory(at: FileManager.covers, includingPropertiesForKeys: nil) {
            return files
        }
        
        return []
    }
    
}
