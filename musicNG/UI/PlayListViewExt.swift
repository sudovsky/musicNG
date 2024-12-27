//
//  PlayListViewExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 23.12.2024.
//

import SwiftUI

extension PlayListView {
    
    func moveFile(source: Playlist, destination: Playlist?, file: FileData) {
        
        var playlist = destination
        if destination == nil {
            let list = Playlist()
            let title = file.title ?? file.name
            let artist = file.artist ?? "Unknown"
            list.name = "\(artist) - \(title)"
            list.sortKey = playlists.all.count
            playlists.all.append(list)
            playlists.save()
            
            _ = FileManager.default.urlForPlaylistSettings(name: list.name)
            
            playlist = list
        }
        
        guard let pl = playlist else { return }
        
        do {
            try FileManager.default.moveItem(at: file.fileURL(), to: FileManager.default.urlForPlaylist(name: pl.name).appendingPathComponent(file.name))
            
            if let data = FilesMetaDB.getDataForPath(file.path) {
                FilesMetaDB.removeData(path: file.path)
                file.path = "\(pl.name)/\(file.name)"
                data.path = file.path
                FilesMetaDB.appendData(dataLine: data)
            } else {
                file.path = "\(pl.name)/\(file.name)"
            }
            
            pl.updateDownloads()
            file.customSortKey = pl.getDownloads().count
            
            source.updateDownloads()
            source.updateCover()
            pl.updateCover()
            
            file.updateTags()
            file.updatePeaks()
            
            MediaPlayer.shared.originalPlaylist.removeAll(where: {$0.path == file.path})
            MediaPlayer.shared.playlist.removeAll(where: {$0.path == file.path})
            
            playlists.reloadView()
        } catch {
            //TODO: - сделать метод показа сообщения
            //            error.localizedDescription.showStandartOkMessage(title: "Ошибка перемещения файла")
            print(error)
            return
        }
        
    }
    
}
