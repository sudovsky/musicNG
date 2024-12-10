//
//  MusicControlView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct MusicControlView: View {
    
    var playlist: Playlist
    @ObservedObject var file = (Variables.shared.currentSong ?? FileData())
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.close)
                    .font(.system(size: 25))
                    .foregroundColor(.main)
                    .padding(.leading, 8)
                    .padding(.bottom, 4)
                    .hidden()

                Text(playlist.name)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)

                Button {
                    //action()
                } label: {
                    Image(.close)
                        .font(.system(size: 25))
                        .foregroundColor(.main)
                        .padding(.trailing, 8)
                        .padding(.bottom, 4)
                }
                .frame(width: 44, alignment: .center)
            }
            
            Spacer()
            
            VinylView()
                .scaleEffect(0.8)
            
            Spacer()
            
            
        }
    }
}

#Preview {
    MusicControlView(playlist: Playlist())
}
