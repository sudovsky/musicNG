//
//  FilesMetaDB.swift
//  musicNG
//
//  Created by Max Sudovsky on 13.12.2024.
//

import SwiftUI

class FilesMetaDB {

    // MARK: - Хранилище
    
    private static let lock = NSRecursiveLock()
    
    private static var storage: [FilesMetaDBLine] = load(FileManager.metaDB) ?? []
    
    private static func locked<T>(_ body: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body()
    }
    
    /// Снимок (копия) массива строк — только для чтения.
    /// Для изменений используйте appendData / removeData / removeAll(where:).
    static var data: [FilesMetaDBLine] {
        locked { storage }
    }
    
    static func restore() {
        _ = locked { storage.count }
    }
    
    // MARK: - Чтение
    
    static func getDataForPath(_ path: String) -> FilesMetaDBLine? {
        locked { storage.first(where: { $0.path == path }) }
    }
    
    static func first(where predicate: (FilesMetaDBLine) -> Bool) -> FilesMetaDBLine? {
        locked { storage.first(where: predicate) }
    }
    
    static func lines(where predicate: (FilesMetaDBLine) -> Bool) -> [FilesMetaDBLine] {
        locked { storage.filter(predicate) }
    }
    
    // MARK: - Изменение
    
    static func appendData(dataLine: FilesMetaDBLine) {
        locked { storage.append(dataLine) }
    }
    
    static func appendData(path: String, title: String, artist: String, cover: Data? = nil, peaks: [Float]? = nil) {
        locked {
            if storage.contains(where: { $0.path == path }) { return }
            
            let fdbl = FilesMetaDBLine()
            fdbl.path = path
            fdbl.title = title
            fdbl.artist = artist
            fdbl.peaks = peaks
            fdbl.saveCover(image: cover)
            
            storage.append(fdbl)
        }
    }
    
    static func removeData(path: String) {
        locked {
            if let fd = storage.first(where: { $0.path == path }) {
                fd.removeCover()
            }
            storage.removeAll(where: { $0.path == path })
        }
    }
    
    static func removeAll(where predicate: (FilesMetaDBLine) -> Bool) {
        locked { storage.removeAll(where: predicate) }
    }
    
    static func updatePeaks(path: String, peaks: [Float]) {
        locked {
            if let fd = storage.first(where: { $0.path == path }) {
                fd.peaks = peaks
            }
        }
    }
    
    static func removePeaks(path: String) {
        locked {
            if let fd = storage.first(where: { $0.path == path }) {
                fd.peaks = nil
            }
        }
    }
    
    // MARK: - Сохранение
    
    private static let ioQueue = DispatchQueue(label: "musicNG.metaDB.io", qos: .utility)
    
    private static var pendingSave: DispatchWorkItem?
    
    static func save() {
        if Thread.isMainThread {
            snapshotAndWrite()
        } else {
            DispatchQueue.main.async { snapshotAndWrite() }
        }
    }
    
    static func scheduleSave(delay: TimeInterval = 2) {
        DispatchQueue.main.async {
            pendingSave?.cancel()
            let item = DispatchWorkItem { snapshotAndWrite() }
            pendingSave = item
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
        }
    }
    
    private struct Record: Encodable {
        let id: String
        let path: String
        let title: String
        let artist: String
        let peaks: [Float]?
        let peaksWidth: CGFloat?
        let peaksHeight: CGFloat?
        
        init(_ line: FilesMetaDBLine) {
            id = line.id
            path = line.path
            title = line.title
            artist = line.artist
            if let p = line.peaks, p.contains(where: { !$0.isFinite }) {
                peaks = p.map { $0.isFinite ? $0 : 0 }
            } else {
                peaks = line.peaks
            }
            peaksWidth = line.peaksWidth.flatMap { $0.isFinite ? $0 : nil }
            peaksHeight = line.peaksHeight.flatMap { $0.isFinite ? $0 : nil }
        }
    }
    
    private static func snapshotAndWrite() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        pendingSave?.cancel()
        pendingSave = nil
        
        let records = data.map(Record.init)
        let url = FileManager.metaDB
        
        var taskID = UIBackgroundTaskIdentifier.invalid
        taskID = UIApplication.shared.beginBackgroundTask(withName: "SaveFilesMetaDB") {
            UIApplication.shared.endBackgroundTask(taskID)
            taskID = .invalid
        }
        
        ioQueue.async {
            do {
                try records.save(url)
            } catch {
                print("FilesMetaDB save error:", error)
            }
            
            DispatchQueue.main.async {
                if taskID != .invalid {
                    UIApplication.shared.endBackgroundTask(taskID)
                    taskID = .invalid
                }
            }
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
