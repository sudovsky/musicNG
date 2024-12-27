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

    @State var currentTag = 0
    @State var currentPL: Playlist? = nil

    @State var showAlert = false
    @State var importing = false
    @State var alertText: String = ""

    @State var title: String = ""
    @State var subtitle: String = ""
    @State var placeholder: String = ""

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(playlists.all, id: \.self) { playlist in
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
                    }
                    .id(UUID())
                    Color(.white)
                }.padding(16)
            }
        }
        .alertFrame(showingAlert: $showAlert, text: $alertText, title: $title, subtitle: $subtitle, placeholder: $placeholder, onDone: tagCompletion)
        .onAppear {
            
        }
    }
}

#Preview {
    PlayListGrid()
}
