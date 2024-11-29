//
//  CurrentSongView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct CurrentSongView: View {
    
    @State var currentSong: FileData? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                (currentSong?.cover?.image() ?? Image(.no))
                    .resizable()
                    .frame(width: 58, height: 58)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
                
                VStack(spacing: 0) {
                    Text(currentSong?.title ?? "Unknown Title")
                        .font(.system(size: 19, weight: .light))
                        .lineLimit(1)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(currentSong?.artist ?? "Unknown Artist")
                        .font(.system(size: 17, weight: .medium))
                        .lineLimit(1)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
            .clipped()
            .background {
                Color.white
            }
            Color.main
                .frame(height: 0.5)
                .opacity(0.1)
        }

    }
}

#Preview {
    CurrentSongView()
}
