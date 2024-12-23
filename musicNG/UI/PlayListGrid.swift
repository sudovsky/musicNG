//
//  PlayListGrid.swift
//  musicNG
//
//  Created by Max Sudovsky on 18.12.2024.
//

import SwiftUI

struct PlayListGrid: View {

    @State var playlists: [Playlist] = []

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(playlists, id: \.self) { playlist in
                        Button {
                            PlaylistCoordinator.shared.currentPlaylist = playlist
                        } label: {
                            PlaylistTile(playlist: playlist, image: playlist.cover?.image() ?? noImage)
                        }
                        .buttonStyle(GrowingButton())
                    }
                    .id(UUID())
                    Color(.white)
                }.padding(16)
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    PlayListGrid()
}
