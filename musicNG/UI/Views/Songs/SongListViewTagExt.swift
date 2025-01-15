//
//  SongListViewTagExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//

import SwiftUI
import ID3TagEditor

extension SongListView {
    
    func updateTag() {
        switch currentTag {
        case 1:
            updateTitle()
        case 2:
            updateArtist()
        case 3:
            importing = true
        case 4:
            shareFile()
        case 5:
            PlaylistSelectionCoordinator.shared.fileToMove = currentFile
            PlaylistSelectionCoordinator.shared.playlistFromMove = playlist
            withAnimation {
                PlaylistSelectionCoordinator.shared.needShowSelection = true
            }
        case 6:
            deleteFile()
        default:
            break
        }
    }

    func tagCompletion(_ newTitle: String) {
        guard let fileData = currentFile else { return }
        
        switch currentTag {
        case 1:
            fileData.updateTextTags(title: newTitle) { newData in
                fileData.saveData(data: newData, async: false)
                fileData.updateTags() {
                    viewUpdater.reloadView()
                    //plist.current = plist.current
                }
                fileData.updatePeaks(slowOnly: true)
            }
        case 2:
            fileData.updateTextTags(artist: newTitle) { newData in
                fileData.saveData(data: newData, async: false)
                fileData.updateTags() {
                    viewUpdater.reloadView()
                    //plist.current = plist.current
                }
                fileData.updatePeaks(slowOnly: true)
            }
        default:
            break
        }
    }
    
    func updateTitle() {
        guard let fileData = currentFile, let ttl = fileData.getCurrentTag(.title) else { return }
        
        title = "Изменение названия"
        subtitle = "Введите название аудиозаписи"
        placeholder = "Название"
        alertText = ttl
        
        showAlert.toggle()
    }
    
    func updateArtist() {
        guard let fileData = currentFile, let ttl = fileData.getCurrentTag(.artist) else { return }
        
        title = "Изменение исполнителя"
        subtitle = "Введите название исполнителя"
        placeholder = "Исполнитель"
        alertText = ttl
        
        showAlert.toggle()
    }
    
    func updateImage(imageData: Data) {
        guard let fileData = currentFile else { return }
        
        fileData.updateCover(imageData: imageData) { newData in
            fileData.saveData(data: newData, async: false)
            fileData.updateTags()
            fileData.updatePeaks(slowOnly: true)
            
            DispatchQueue.main.async {
                viewUpdater.reloadView()
                //plist.current = plist.current
            }
            
            DispatchQueue.global().async {
                FilesMetaDB.save()
            }
        }
    }
    
    func shareFile() {
        guard let fileData = currentFile else { return }
        
        share(items: [fileData.fileURL()])
    }
    
    func deleteFile() {
        guard let fileData = currentFile else { return }
        
        if fileData.isDirectory { return }
        
        MediaPlayer.shared.originalPlaylist.removeAll(where: {$0.path == fileData.path})
        MediaPlayer.shared.playlist.removeAll(where: {$0.path == fileData.path})

        FilesMetaDB.removeData(path: fileData.path)
        fileData.removeDownload()
        
        fileList.removeAll { $0.path == fileData.path }
        
        currentFile = nil
        
        playlist.updateDownloads()
        viewUpdater.reloadView()
        //plist.current = plist.current
    }
    
}

@discardableResult
func share(
    items: [Any],
    excludedActivityTypes: [UIActivity.ActivityType]? = nil
) -> Bool {
    guard let source = UIApplication.window?.rootViewController else {
        return false
    }
    let vc = UIActivityViewController(
        activityItems: items,
        applicationActivities: nil
    )
    vc.excludedActivityTypes = excludedActivityTypes
    vc.popoverPresentationController?.sourceView = source.view
    source.present(vc, animated: true)
    return true
}
