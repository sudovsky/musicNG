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
            SongTile(shadow: false)
                .padding([.top, .leading], 6)
                .opacity(0.2)
            SongTile(shadow: false)
                .padding([.top, .leading], 3)
                .padding([.trailing, .bottom], 3)
                .opacity(0.4)
            SongTile(artistVisible: false, image: playlist.cover?.image(), track: playlist.name, shadow: false)
                .padding([.trailing, .bottom], 6)
            
        }
        .shadow(color: commonShadowColor, radius: 5.4, x: 2.7, y: 5.5)
    }
}

#Preview {
    PlaylistTile(playlist: Playlist())
}
