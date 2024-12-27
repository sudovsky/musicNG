//
//  PlayListGridTagExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 23.12.2024.
//

import SwiftUI

extension PlayListGrid {
    
    func updateTag() {
        switch currentTag {
        case 0:
            break
        case 1:
            updateTitle()
        case 2:
            importing = true
        case 3:
            shareFile()
        case 4:
            deleteFile()
        default:
            break
        }
    }
    
    func tagCompletion(_ newTitle: String) {
        guard let playlist = currentPL else { return }
        
        let str = newTitle.trim()
        
        let lastUrl = FileManager.default.urlForPlaylist(name: playlist.name)
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let newUrl = documentsUrl.appendingPathComponent("Playlists").appendingPathComponent(str)

        do {
            try FileManager.default.moveItem(at: lastUrl, to: newUrl)
        } catch {
            //error.localizedDescription.showStandartOkMessage()
            return
        }

        let oldMeta = FilesMetaDB.data.filter({$0.path.starts(with: playlist.name + "/")})
        
        for meta in oldMeta {
            meta.path = meta.path.replacingOccurrences(of: playlist.name + "/", with: str + "/")
        }

        FilesMetaDB.save()
        
        playlist.name = str
        
        Playlists.shared.save()
        
        
        //TODO: - view updation not working
        playlists.reloadView()
        
        currentPL = nil
        
    }
    

    func updateTitle() {
        guard let playlist = currentPL else { return }
        
        title = "Изменение названия"
        subtitle = "Введите название плейлиста"
        placeholder = "Название"
        alertText = playlist.name
        
        showAlert.toggle()
    }

    func updateImage(imageData: Data) {
        guard let playlistToChangeImage = currentPL else { return }
        
        let coversUrl = FileManager.covers

        let fileURL = coversUrl.appendingPathComponent(playlistToChangeImage.id).appendingPathExtension("jpg")
        do {
            try imageData.write(to: fileURL, options: .atomic)
        } catch let error {
            print(error.localizedDescription)
//            error.localizedDescription.showStandartOkMessage()
        }
        
        playlistToChangeImage.cover = imageData
        
        playlists.all.first(where: { $0.id == playlistToChangeImage.id })?.cover = imageData
        
        playlists.save()

        //TODO: - view updation not working
        playlists.reloadView()
        
        currentPL = nil
    }
    
    func shareFile() {
        guard let playlist = currentPL else { return }
        
        share(items: playlist.getDownloads().map { $0.fileURL() } )
    }
    
    func deleteFile() {
        guard let playlist = currentPL else { return }

        let fileURL = FileManager.default.urlForPlaylist(name: playlist.name)
        do {
            if playlist.cover != nil {
                let coverUrl = FileManager.covers
                let coverFileURL = coverUrl.appendingPathComponent(playlist.id).appendingPathExtension("jpg")
                try FileManager.default.removeItem(at: coverFileURL)
            }
        } catch {
            print(error)
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            playlists.all.removeAll(where: { $0.id == playlist.id })
            playlists.save()
        } catch {
            print(error)
        }
    }

}
