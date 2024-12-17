//
//  MusicControlView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct MusicControlView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var variables = Variables.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.close)
                    .titleButtonImage(.leading)
                    .hidden()
                
                Text(Variables.shared.currentPlaylist.name)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                
                Button {
                    dismiss()
                } label: {
                    Image(.close)
                        .titleButtonImage(.trailing)
                }
                .frame(width: 44, alignment: .center)
            }
            
            Spacer()
            
            VinylView()
                .scaleEffect(0.8)
            
            Spacer()
            
            Text((variables.currentSong?.title ?? variables.currentSong?.name) ?? "")
                .multilineTextAlignment(.center)
                .font(.system(size: 20))
                .padding(.horizontal, 16)
            
            if let artist = variables.currentSong?.artist {
                Text(artist)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18))
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
            
            ProgressView(peaks: variables.currentSong?.peaks.peaks ?? Peak.empty, maxPeak: variables.currentSong?.peaks.maxPeak ?? 1)
                .padding(.bottom, 22)
            
            HStack(alignment: .center, spacing: 25) {
                
                Button {
                    _ = MediaPlayer.shared.switchShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .opacity(MediaPlayer.shared.shuffled == .off ? 0.3 : 1)
                .shadowed()
                
                PlayControlButton(imageName: "backward.end.fill") {
                    MediaPlayer.shared.prevFile()
                }
                .frame(width: 44, height: 44)
                PlayControlButton(isBig: true) {
                    if MediaPlayer.shared.paused {
                        MediaPlayer.shared.unpause()
                    } else {
                        MediaPlayer.shared.pause()
                    }
                }
                .frame(width: 74, height: 74)
                PlayControlButton(imageName: "forward.end.fill") {
                    MediaPlayer.shared.nextFile()
                }
                .frame(width: 44, height: 44)
                
                Button {
                    _ = MediaPlayer.shared.switchRepeat()
                } label: {
                    Image(systemName: MediaPlayer.shared.repeated == .one ? "repeat.1" : "repeat")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .opacity(MediaPlayer.shared.repeated == .off ? 0.3 : 1)
                .shadowed()
                
            }
            .padding(.bottom, 35)
            
            
        }
        .transition(.opacity.animation(.spring))
    }
    
}

#Preview {
    MusicControlView()
}
