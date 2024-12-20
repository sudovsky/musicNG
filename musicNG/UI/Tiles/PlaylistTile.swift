//
//  PlaylistTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

struct PlaylistTile: View {
    
    var playlist: Playlist
    var image: Image

    var body: some View {
        ZStack {
            image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .cornerRadius(commonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: commonCornerRadius)
                        .stroke(commonBorderColor, lineWidth: commonBorderWidth)
                )
                .padding([.top, .leading], 6)
                .opacity(0.2)
            image
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .cornerRadius(commonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: commonCornerRadius)
                        .stroke(commonBorderColor, lineWidth: commonBorderWidth)
                )
                .padding([.top, .leading], 3)
                .padding([.trailing, .bottom], 3)
                .opacity(0.4)
            SongTile(image: image, artistVisible: false, track: playlist.name, shadow: false)
                .padding([.trailing, .bottom], 6)
            
        }
        .aspectRatio(contentMode: .fit)
//        .cornerRadius(commonCornerRadius)
        .shadowed()
    }
}

#Preview {
    PlaylistTile(playlist: Playlist(), image: noImage)
}
