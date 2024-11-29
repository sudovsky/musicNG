//
//  PlaylistTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

struct PlaylistTile: View {
    
    var playlist: Playlist
    @State var image1: Image? = nil
    @State var image2: Image? = nil
    @State var image3: Image? = nil


    var body: some View {
        ZStack {
            image1?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(commonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: commonCornerRadius)
                        .stroke(commonBorderColor, lineWidth: commonBorderWidth)
                )
                .padding([.top, .leading], 6)
                .opacity(0.2)
            image2?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(commonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: commonCornerRadius)
                        .stroke(commonBorderColor, lineWidth: commonBorderWidth)
                )
                .padding([.top, .leading], 3)
                .padding([.trailing, .bottom], 3)
                .opacity(0.4)
            SongTile(artistVisible: false, image: image3, track: playlist.name, shadow: false)
                .padding([.trailing, .bottom], 6)
            
        }
        .shadowed()
        .onAppear {
            if image1 != nil {
                return
            }
            
            DispatchQueue.global().async {
                let img1 = playlist.cover?.image() ?? noImage
                let img2 = playlist.cover?.image() ?? noImage
                let img3 = playlist.cover?.image() ?? noImage
                
                DispatchQueue.main.async {
                    image1 = img1
                    image2 = img2
                    image3 = img3
                }
            }
        }
    }
}

#Preview {
    PlaylistTile(playlist: Playlist())
}
