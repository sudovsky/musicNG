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
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(playlists) { playlist in
                            NavigationLink {
                                SongListView(playlist: playlist)
                            } label: {
                                PlaylistTile(playlist: playlist, image: playlist.cover?.image() ?? noImage)
                            }
                        }
                        Color(.back)
                    }.padding(16)
                }
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    PlayListGrid()
}
