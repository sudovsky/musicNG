//
//  SongListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 12.12.2024.
//

import SwiftUI

struct SongListView: View {

    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewUpdater = ViewUpdater()
    @ObservedObject var plist = PlaylistCoordinator.shared

    var playlist: Playlist
    @State var fileList: [FileData] = []
    
    @State var showAlert = false
    @State var importing = false
    @State var alertText: String = ""

    @State var title: String = ""
    @State var subtitle: String = ""
    @State var placeholder: String = ""
    
    @State var currentTag = 0
    @State var currentFile: FileData? = nil

    @State var reorder = true

    @State var canDismiss = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ReorderableForEach($fileList, allowReordering: $reorder) { file, isDragged in
                        Button {

                            Variables.shared.currentSong = file
                            
                            let findx = fileList.firstIndex(where: { $0.id == file.id })
                            
                            PositionCoordinator.shared.position = 0
                            
                            MediaPlayer.shared.initPlayback(playlist: fileList, index: Int(findx ?? 0), playlistName: playlist.name)
                        } label: {
                            SongTile(image: file.cover?.image() ?? noImage, artistVisible: file.artist != nil, artist: file.artist ?? "", track: file.title ?? file.name, shadow: true, gradient: true)
                                .songContext(file: file) { fileToUpdate in
                                    viewUpdater.reloadView()
                                    fileToUpdate.updatePeaks(slowOnly: true)
                                } action: { tag, file in
                                    currentTag = tag
                                    currentFile = file
                                    updateTag()
                                }
                        }
                        .buttonStyle(GrowingButton())
                        .overlay(isDragged ? Color.back.opacity(0.6) : Color.clear)
                    } onDone: {
                        DispatchQueue.global().async {
                            var index = 0
                            for file in fileList {
                                file.customSortKey = index
                                index += 1
                            }
                            
                            try? fileList.save(FileManager.default.urlForPlaylistSettings(name: playlist.name))
                            
                            MediaPlayer.shared.playlist = fileList
                        }
                    }
                    Color(.back)
                }
                .padding([.horizontal, .top], 16)
            }
            .imageSelection(importing: $importing, onGetImage: updateImage(imageData:))

        }
        .background {
            Color.back
        }
        .alertFrame(showingAlert: $showAlert, text: $alertText, title: $title, subtitle: $subtitle, placeholder: $placeholder, onDone: tagCompletion)
        .onReceive(plist.$current) { list in
            if !canDismiss { return }
            
            if list == nil {
                dismiss()
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                fileList = playlist.getDownloads(readMetadata: true)
                DispatchQueue.main.async {
//                    withAnimation {
                        viewUpdater.reloadView()
//                    }
                }
            }
        }
        .onAppear() {
            PlaylistCoordinator.shared.current = playlist
            canDismiss = true
            fileList = playlist.getDownloads(readMetadata: true)
        }
        .onDisappear() {
            PlaylistCoordinator.shared.current = nil
            canDismiss = false
        }
        .toolbar(.hidden)
    }
    
}

#Preview {
    SongListView(playlist: Playlist())
}
