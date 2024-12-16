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
            
            ProgressView(peaks: variables.currentSong?.getPeaks() ?? Peak.test, maxPeak: variables.currentSong?.maxPeak() ?? 1)
                .padding(.bottom, 22)            
            
            HStack(alignment: .center, spacing: 25) {
                
                Button {
                    
                } label: {
                    Image(systemName: "shuffle")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .shadowed()

                PlayControlButton(imageName: "backward.end.fill") {
                    withAnimation {
                        prevSong()
                    }
                }
                    .frame(width: 44, height: 44)
                PlayControlButton(isBig: true)
                    .frame(width: 74, height: 74)
                PlayControlButton(imageName: "forward.end.fill") {
                    withAnimation {
                        nextSong()
                    }
                }
                    .frame(width: 44, height: 44)
                
                Button {
                    
                } label: {
                    Image(systemName: "repeat")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .shadowed()

            }
            .padding(.bottom, 35)
            
            
        }
        .transition(.opacity.animation(.spring))
    }
    
    func nextSong() {
        let sl = Variables.shared.songList
        
        if sl.count == 0 { return }
        
        guard let currentIndex = sl.firstIndex(where: {$0.id == Variables.shared.currentSong?.id}) else { return }
        
        if currentIndex < sl.count - 1 {
            Variables.shared.currentSong = sl[currentIndex + 1]
        } else {
            Variables.shared.currentSong = sl[0]
        }
    }
    
    func prevSong() {
        let sl = Variables.shared.songList
        
        if sl.count == 0 { return }
        
        guard let currentIndex = sl.firstIndex(where: {$0.id == Variables.shared.currentSong?.id}) else { return }
        
        if currentIndex > 0 {
            Variables.shared.currentSong = sl[currentIndex - 1]
        } else {
            Variables.shared.currentSong = sl[sl.count - 1]
        }
    }

}

#Preview {
    MusicControlView()
}
