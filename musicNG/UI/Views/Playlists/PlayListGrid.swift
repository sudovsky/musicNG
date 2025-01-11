//
//  PlayListGrid.swift
//  musicNG
//
//  Created by Max Sudovsky on 18.12.2024.
//

import SwiftUI

struct PlayListGrid: View {

    @ObservedObject var playlists = Playlists.shared
    @ObservedObject var viewUpdater = ViewUpdater()

    @State var pls: [Playlist] = []

    @State var currentTag = 0
    @State var currentPL: Playlist? = nil

    @State var showAlert = false
    @State var importing = false
    @State var alertText: String = ""

    @State var title: String = ""
    @State var subtitle: String = ""
    @State var placeholder: String = ""
    @State var reorder = true

    @State var showingTagEditor: Bool = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ReorderableForEach($pls, allowReordering: $reorder) { playlist, isDragged in
                        Button {
                            PlaylistCoordinator.shared.currentPlaylist = playlist
                        } label: {
                            PlaylistTile(playlist: playlist, image: playlist.cover?.image() ?? noImage)
                                .playlistContext(playlist: playlist) {
                                    viewUpdater.reloadView()
                                } action: { tag, playlist in
                                    currentTag = tag
                                    currentPL = playlist
                                    updateTag()
                                }
                        }
                        .buttonStyle(GrowingButton())
                        .overlay(isDragged ? Color.back.opacity(0.6) : Color.clear)
                    }
                    onDone: {
                        DispatchQueue.global().async {
                            var index = 0
                            pls.forEach { pl in
                                pl.sortKey = index
                                index += 1
                            }
                            
                            DispatchQueue.main.async {
                                playlists.all = pls
                                playlists.save()
                            }
                        }
                    }
                    .id(UUID())
                    Color(.back)
                }
                .padding(16)
            }
            
            ImageSelectionView(importing: $importing, onGetImage: updateImage(imageData:))

        }
        .tagEditorFrame(for: $currentPL, isVisible: $showingTagEditor)
        .onReceive(playlists.$all, perform: { value in
            pls = value
        })
        .alertFrame(showingAlert: $showAlert, text: $alertText, title: $title, subtitle: $subtitle, placeholder: $placeholder, onDone: tagCompletion)
        .onAppear {
            
        }
    }
}

#Preview {
    PlayListGrid()
}
