//
//  FileDataExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 28.12.2024.
//

import SwiftUI

extension FileData {
    
    func updatePeaks(slowOnly: Bool = false) {
        MediaPlayer.shared.readBuffer(fileURL(), notify: false) { fast, data in
            if fast {
                if slowOnly { return }
                
                self.fastPeaks = data
                
                if Variables.shared.currentSong?.id == self.id {
                    DispatchQueue.main.async {
                        withAnimation {
                            Variables.shared.currentSong = self
                        }
                    }
                }
            } else {
                self.slowPeaks = data

                if Variables.shared.currentSong?.id == self.id {
                    DispatchQueue.main.async {
                        withAnimation {
                            Variables.shared.currentSong = self
                        }
                    }
                }

                if let dataLine = FilesMetaDB.data.first(where: {$0.path == self.path}) {
                    dataLine.peaks = data
                }
            }
        }
    }

    static func getFilesFromShare() {
        guard let commonurl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.cloudunion.music")?.appendingPathComponent("Downloads") else { return }
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: commonurl, includingPropertiesForKeys: nil) else { return }
 
        
        var settings = [String:[String]]()
        
        if let sett = readJson(file: FileManager.globalDownloadsSettingsFile, as: [String:[String]].self) {
            settings = sett
        }

        if Playlists.shared.all.isEmpty {
            Playlists.shared.reload() { _ in
                proceedReading(settings: settings, files: files, commonurl: commonurl)
            }
        } else {
            proceedReading(settings: settings, files: files, commonurl: commonurl)
        }
    }
    
    private static func proceedReading(settings: [String:[String]], files: [URL], commonurl: URL) {
        
        for setting in settings {
            if !Playlists.shared.all.contains(where: {$0.name == setting.key}) {
                let list = Playlist()
                list.name = setting.key
                list.sortKey = Playlists.shared.all.count
                Playlists.shared.all.append(list)
                
                _ = FileManager.default.urlForPlaylistSettings(name: setting.key)
            }
        }
        
        var urls = [URL]()
        
        for file in files {
            if file.lastPathComponent == "Settings.json" {
                continue
            }
            
            urls.append(file)
        }
        
        if urls.count == 0 {
            try? FileManager.default.removeItem(at: commonurl)
            return
        }
        
        var datas = [String:Data]()
        for url in urls {
            if url.startAccessingSecurityScopedResource() {
                do {
                    let data = try Data(contentsOf: url)
                    datas[url.lastPathComponent] = data
                } catch {
                    print(error)
                }
                
                url.stopAccessingSecurityScopedResource()
            } else {
                do {
                    let data = try Data(contentsOf: url)
                    datas[url.lastPathComponent] = data
                } catch {
                    print(error)
                }
            }
        }
        
        for data in datas {
            guard let pname = settings.keys.first(where: { settings[$0]!.contains(where: { $0 == data.key })}), let playlist = Playlists.shared.all.first(where: { $0.name == pname }) else {
                continue
            }
            
            let file = FileData()
            file.path = "\(playlist.name)/\(data.key)"
            file.saveData(data: data.value)
        }
        
        Playlists.shared.save()
        
        Playlists.shared.reload() { _ in }
        
        try? FileManager.default.removeItem(at: commonurl)
    }

}
