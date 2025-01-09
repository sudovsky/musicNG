//
//  MusicControlView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct MusicControlView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?

    @ObservedObject var variables = Variables.shared
    @ObservedObject var pb = PlaybackCoordinator.shared

    var body: some View {
        if verticalSizeClass == .compact {
            HStack(spacing: 0) {
                VinylView()
                    .scaleEffect(0.85)
                verticalPart()
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded({ val in
                        let distX = val.location.x - val.startLocation.x
                        let disty = val.location.y - val.startLocation.y
                        
                        if abs(distX) < abs(disty), disty > 0 {
                            dismiss()
                        }
                    })
            )
            .transition(.opacity.animation(.spring))
        } else {
            verticalPart()
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded({ val in
                            let distX = val.location.x - val.startLocation.x
                            let disty = val.location.y - val.startLocation.y
                            
                            if abs(distX) < abs(disty), disty > 0 {
                                dismiss()
                            }
                        })
                )
                .transition(.opacity.animation(.spring))
        }
    }
    
    func verticalPart() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.close)
                    .titleButtonImage(.leading)
                    .hidden()
                
                Text(Variables.shared.currentPlaylist?.name ?? "")
                    .font(trackFont)
                    .multilineTextAlignment(.center)
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
            .padding(.vertical, verticalSizeClass == .compact ? 16 : 0)
            
            Spacer()
            
            if verticalSizeClass != .compact {
                VinylView()
                    .scaleEffect(0.85)
            }

            Spacer()
            
            Text((variables.currentSong?.title ?? variables.currentSong?.name) ?? "")
                .multilineTextAlignment(.center)
                .font(mcTrackFont)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            Text(variables.currentSong?.artist ?? "Unknown Artist")
                .multilineTextAlignment(.center)
                .font(mcArtistFont)
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 42)
            
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
                .opacity(pb.shuffleMode == 0 ? 0.3 : 1)
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
                    Image(systemName: pb.repeatMode == 1 ? "repeat.1" : "repeat")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .opacity(pb.repeatMode == 0 ? 0.3 : 1)
                .shadowed()
                
            }
            .padding(.bottom, verticalSizeClass == .compact ? 16 : 35)
        }
    }
}

#Preview {
    MusicControlView()
}
