//
//  CurrentSongView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct CurrentSongView: View {
    
    @ObservedObject var variables = Variables.shared

    @State private var blur: CGFloat = 16

    @State private var showMusicControl: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                (variables.currentSong?.cover?.image() ?? Image(.no))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 58, height: 58)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
                
                VStack(spacing: 0) {
                    Text(variables.currentSong?.title ?? (variables.currentSong?.name ?? "Unknown Title"))
                        .font(csTrackFont)
                        .lineLimit(1)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(variables.currentSong?.artist ?? "Unknown Artist")
                        .font(csArtistFont)
                        .lineLimit(1)
                        .padding(.trailing, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
            .clipped()
            .background {
                Color.back
            }
            Color.main
                .frame(height: 0.5)
                .opacity(0.1)
        }
        .blur(radius: blur)
        .transition(.scale(scale: 0.2))
        .onAppear() {
            withAnimation(.easeOut.speed(1.8)) {
                blur = 0
            }
        }
        .onTapGesture {
            showMusicControl = true
        }
        //showing MusicControlView
        .fullScreenCover(isPresented: $showMusicControl) {
            MusicControlView()
        }
        .transaction({ transaction in
          // disable the default FullScreenCover animation
          transaction.disablesAnimations = true

          // add custom animation for presenting and dismissing the FullScreenCover
            //transaction.animation = .linear(duration: 0.2)
        })
//        .onReceive(variables.$currentSong) { newTitle in
//            // 4
//            withAnimation {
//                blur = 0
//            }
//        }
    }
}

#Preview {
    CurrentSongView()
}
