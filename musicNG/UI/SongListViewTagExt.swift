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
        default:
            break
        }
    }

    func tagCompletion(_ newTitle: String) {
        guard let fileData = currentFile else { return }
        
        switch currentTag {
        case 1:
            fileData.updateTextTags(title: newTitle) { newData in
                fileData.saveData(data: newData)
                fileData.updateTags() {
                    viewUpdater.reloadView()
                }
            }
        case 2:
            fileData.updateTextTags(artist: newTitle) { newData in
                fileData.saveData(data: newData)
                fileData.updateTags() {
                    viewUpdater.reloadView()
                }
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
    
}
