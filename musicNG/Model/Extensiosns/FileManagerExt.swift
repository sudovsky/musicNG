//
//  FileManagerExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import Foundation

// MARK: - Local

extension FileManager {
    
    static var root: URL { FileManager.default.getUrlForPLRoot() }
    static var covers: URL { FileManager.default.getUrlForCovers() }
    static var temp: URL { FileManager.default.getUrlForTemp() }
    static var playlistsSettings: URL { FileManager.default.getUrlForPlaylistsSettings() }
    static var metaDB: URL { FileManager.default.getUrlForMetaDB() }
    static var appSettings: URL { FileManager.default.urlForAppSettings() }

    private func getUrlForMetaDB() -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!

        //TODO: - remove in future versions
        hideFile(rootUrl: documentsUrl, filename: "localDB")
        //

        let currentPath = documentsUrl.appendingPathComponent(".localDB").appendingPathExtension("json")
        
        return currentPath
    }

    private func getUrlForPLRoot() -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDirPath = documentsUrl.appendingPathComponent("Playlists")

        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }

        return currentDirPath
    }
    
    private func getUrlForCovers() -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDirPath = documentsUrl.appendingPathComponent(".Covers")
        
        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }

        return currentDirPath
    }
    
    private func getUrlForTemp() -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDirPath = documentsUrl.appendingPathComponent(".Temp")

        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }

        return currentDirPath
    }
    
    func createTempFile(data: Data, ext: String) -> URL {
        let tempPath = getUrlForTemp().appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
        
        do {
            try data.write(to: tempPath, options: .atomic)
        } catch {
            print(error.localizedDescription, "Can'not save local db")
        }

        return tempPath
    }
    
    func deleteTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            
        }
    }
    
    private func getUrlForPlaylistsSettings() -> URL {
        
        //TODO: - remove in future versions
        hideFile(rootUrl: getUrlForPLRoot())
        //
        
        return getUrlForPLRoot().appendingPathComponent(".Settings").appendingPathExtension("json")
    }
    
    func urlForPlaylist(name: String) -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!
        let currentDirPath = documentsUrl.appendingPathComponent("Playlists").appendingPathComponent(name)

        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }

        return currentDirPath
    }
    
    func urlForPlaylistSettings(name: String) -> URL {
        let pp = getUrlForPLRoot().appendingPathComponent(name)
        if !fileExists(atPath: pp.path) {
            try? createDirectory(at: pp, withIntermediateDirectories: true)
        }
        
        //TODO: - remove in future versions
        hideFile(rootUrl: pp)
        //
        
        return pp.appendingPathComponent(".Settings").appendingPathExtension("json")
    }
    
    private func urlForAppSettings() -> URL {
        let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl.appendingPathComponent(".Settings").appendingPathExtension("json")
    }
    
    //TODO: - remove in future versions
    func hideFile(rootUrl pp: URL, filename: String = "Settings") {
        if fileExists(atPath: pp.appendingPathComponent(filename).appendingPathExtension("json").path) {
            
            if fileExists(atPath: pp.appendingPathComponent(".\(filename)").appendingPathExtension("json").path) {
                do {
                    try FileManager.default.removeItem(at: pp.appendingPathComponent(".\(filename)").appendingPathExtension("json"))
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            do {
                try FileManager.default.copyItem(at: pp.appendingPathComponent(filename).appendingPathExtension("json"), to: pp.appendingPathComponent(".\(filename)").appendingPathExtension("json"))
                
                try FileManager.default.removeItem(at: pp.appendingPathComponent(filename).appendingPathExtension("json"))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

// MARK: - Global

extension FileManager {
    
    static var globalCoversDir: URL { FileManager.default.globalURLForCovers() }
    static var globalPlaylistsDir: URL { FileManager.default.globalURLForPlaylists() }
    static var globalPlaylistsSettingsFile: URL { FileManager.default.globalURLForPlaylistsSettingsFile() }
    static var globalDownloadsDir: URL { FileManager.default.globalURLForDownloads() }
    static var globalDownloadsSettingsFile: URL { FileManager.default.globalURLForDownloadsSettingsFile() }

    private func globalURLForCovers() -> URL {
        let currentDirPath = containerURL(forSecurityApplicationGroupIdentifier: "group.ru.cloudunion.music")!.appendingPathComponent(".Covers")

        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }
        
        return currentDirPath
    }

    private func globalURLForPlaylists() -> URL {
        let currentDirPath = containerURL(forSecurityApplicationGroupIdentifier: "group.ru.cloudunion.music")!.appendingPathComponent("Playlists")

        if !fileExists(atPath: currentDirPath.path) {
            try? createDirectory(at: currentDirPath, withIntermediateDirectories: true)
        }
        
        return currentDirPath
    }

    private func globalURLForPlaylistsSettingsFile() -> URL {
        //TODO: - remove in future versions
        hideFile(rootUrl: globalURLForPlaylists())
        //

        return globalURLForPlaylists().appendingPathComponent(".Settings").appendingPathExtension("json")
    }

    private func globalURLForDownloads() -> URL {
        let commonurl = containerURL(forSecurityApplicationGroupIdentifier: "group.ru.cloudunion.music")!.appendingPathComponent("Downloads")
        
        if !fileExists(atPath: commonurl.path) {
            try? createDirectory(at: commonurl, withIntermediateDirectories: true)
        }

        return commonurl
    }

    private func globalURLForDownloadsSettingsFile() -> URL {
        //TODO: - remove in future versions
        hideFile(rootUrl: globalURLForDownloads())
        //
        return globalURLForDownloads().appendingPathComponent(".Settings").appendingPathExtension("json")
    }

}

