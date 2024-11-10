//
//  PlaylistTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

struct PlaylistTile: View {
    
    var playlist: Playlist
    
    var body: some View {
        ZStack {
            SongTile(artistVisible: false, shadow: false)
                .padding([.top, .leading], 6)
                .opacity(0.2)
            SongTile(artistVisible: false, shadow: false)
                .padding([.top, .leading], 3)
                .padding([.trailing, .bottom], 3)
                .opacity(0.4)
            SongTile(artistVisible: false, image: playlist.cover?.image(), track: playlist.name, shadow: false)
                .padding([.trailing, .bottom], 6)
            
        }
        .shadowed()
    }
}

#Preview {
    PlaylistTile(playlist: Playlist())
}
