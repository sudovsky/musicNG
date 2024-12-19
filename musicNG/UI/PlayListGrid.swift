//
//  PlayListGrid.swift
//  musicNG
//
//  Created by Max Sudovsky on 18.12.2024.
//

import SwiftUI

struct PlayListGrid: View {

    @State var playlists: [Playlist] = []
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationView {
                ScrollView {
                    let mars = playlists.getManyArrays()
                    VStack(alignment: .center, spacing: 16) {
                        ForEach(mars, id: \.self) { elem in
                            HStack(alignment: .center, spacing: 16) {
                                
                                ForEach(elem, id: \.self) { first in
                                    NavigationLink {
                                        SongListView(playlist: first)
                                    } label: {
                                        PlaylistTile(playlist: first, image: first.cover?.image() ?? noImage)
                                    }
                                }
                                
                                if elem.count == 1 {
                                    PlaylistTile(playlist: Playlist(), image: Playlist().cover?.image() ?? noImage)
                                        .opacity(0)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
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
