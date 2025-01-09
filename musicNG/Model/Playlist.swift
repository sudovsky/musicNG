//
//  Playlist.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import Foundation

class Playlist: Hashable, Codable, Identifiable {
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case date
        case songsSort
        case sortKey
    }
    
    var id = UUID().uuidString
    var name = "Неизвестный"
    var date = Date()
    var songsSort: SortType = .userDefined
    
    var sortKey = 0
    
    var cover: Data?
    
    init() {}
    
    init(name: String) {
        self.name = name
    }
    
    func getCoverFromSongs(_ source: [FileData]? = nil) -> Data? {
        let files = source ?? getDownloads()
        
        for file in files {
            file.readMetadata()
            if let cover = file.cover {
                return cover
            }
        }
        
        return nil
    }
    
    func urlForPlaylistCover() -> URL? {
        let currentDirPath = FileManager.covers.appendingPathComponent(id).appendingPathExtension("jpg")

        if FileManager.default.fileExists(atPath: currentDirPath.path) {
            return currentDirPath
        }
        
        return nil
    }

    func updateCover() {
        if let url = urlForPlaylistCover() {
            cover = try? Data(contentsOf: url)
        } else {
            cover = getCoverFromSongs()
        }
    }
    
    func getFilesFromDisk() -> [String] {
        var listFromDisk = [String]()
        
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: FileManager.default.urlForPlaylist(name: name), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        for url in directoryContents ?? [] {
            if !url.isFileURL || standarts.first(where: { $0 == url.pathExtension.uppercased() }) == nil {
                continue
            }
            
            listFromDisk.append(url.lastPathComponent)
        }
        
        return listFromDisk
    }
    
    func getDownloads(readMetadata: Bool = false) -> [FileData] {
        var files = [FileData]()
        
        files = load(FileManager.default.urlForPlaylistSettings(name: name)) ?? [FileData]()
        
        for file in files {
            file.path = "\(name)/\(file.name)"
            
            if readMetadata {
                file.readMetadata()
            }
        }
        
        return files.sorted(by: { $0.customSortKey < $1.customSortKey })
    }
    
    func updateDownloads() {
        
        var files = getDownloads()
        let listFromDisk = getFilesFromDisk()
        var needRewrite = false
        
        //remove that deleted
        var i = 0
        while i < files.count {
            let file = files[i]
            if listFromDisk.first(where: {$0 == file.name || $0 == file.name.nameWithoutDot()}) == nil {
                FilesMetaDB.removeData(path: file.path)
                files.remove(at: i)
                needRewrite = true
            }
            i += 1
        }
        
        //add whats new
        for pl in listFromDisk {
            if files.first(where: {$0.name == pl || $0.name.nameWithoutDot() == pl}) == nil {
                let fd = FileData(name: pl, path: "\(name)/\(pl)", customSortKey: files.count)
                
                files.append(fd)
                needRewrite = true
            }
        }
        
        if needRewrite {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                try? files.save(FileManager.default.urlForPlaylistSettings(name: self.name))
            }
        }
        
    }

    
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func getAll(withCovers: Bool = true, updatedResult: (([Playlist]) -> Void)? = nil) -> [Playlist] {
        
        let path = FileManager.playlistsSettings
        
        let plsts = load(path) ?? [Playlist(), Playlist(), Playlist()] as! [Playlist]
        
        if updatedResult != nil {
            plsts.updatedPlaylists { newLists in
                for playlist in newLists {
                    playlist.updateDownloads()
                    playlist.updateCover()
                }
                
                updatedResult?(newLists)
            }
        } else if withCovers {
            for playlist in plsts {
                playlist.updateCover()
            }
        }

        return plsts
    }
}

extension Array where Element: Playlist {
    
    func updatedPlaylists(onDone: @escaping ([Playlist]) -> Void) {

        var result: [Playlist] = self
        
        DispatchQueue.global().async {
            
            var listsFromDisk = [String]()
            
            let directoryContents = try? FileManager.default.contentsOfDirectory(at: FileManager.root, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for url in directoryContents ?? [] {
                if !url.isDirectory {
                    continue
                }
                
                listsFromDisk.append(url.lastPathComponent)
            }
            
            let toRemove = result.compactMap { playlist in
                listsFromDisk.first(where: { $0 == playlist.name }) == nil ? playlist : nil
            }
            
            let new = listsFromDisk.compactMap { el in
                first(where: {$0.name == el})?.name == nil ? el : nil
            }
            
            for name in new {
                result.append(Playlist(name: name))
            }
            
            for playlist in toRemove {
                result.removeAll(where: { $0.id == playlist.id })
            }
            
            if !toRemove.isEmpty {
                for removeItem in toRemove {
                    FilesMetaDB.data.removeAll(where: { $0.path.hasPrefix(removeItem.name) })
                }
                
                DispatchQueue.global(qos: .background).async {
                    FilesMetaDB.save()
                }
            }
            
            if !new.isEmpty || !toRemove.isEmpty {
                DispatchQueue.global(qos: .background).async {
                    try? result.save(FileManager.playlistsSettings)
                }
            }
            
            DispatchQueue.main.async {
                onDone(result)
            }
        }

    }
    
}
