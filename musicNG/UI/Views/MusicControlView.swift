//
//  MusicControlView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct MusicControlView: View {
    
    @Binding var currentFrame: CurrentFrameID
    var lastCurrentFrame: CurrentFrameID = .playlist

    var animation: Namespace.ID

    @Environment(\.dismiss) var dismiss

    @ObservedObject var variables = Variables.shared
    @ObservedObject var pb = PlaybackCoordinator.shared
    @StateObject private var orientationCoordinator = OrientationCoordinator.shared

    @State private var isVertical: Bool? = nil
    @State private var imageOffset: CGSize = CGSize.zero
    @State private var imageScale: CGFloat = 0.85
    @State private var imageOpacity: CGFloat = 1
    @State private var commonOpacity: CGFloat = 0

    var body: some View {
        //TODO: - divide screen ровно пополам for ipad
        if isVertical == false {
            HStack(spacing: 0) {
                VinylView()
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .vinilGesture(canSwitchSong: false) {
                        close()
                    }

                Spacer()
                
                VStack(spacing: 0) {
                    topPart()
                        .opacity(commonOpacity)

                    Spacer()
                    
                    verticalPart()
                        .opacity(commonOpacity)
                        .frame(maxWidth: orientationCoordinator.size.width / 2)
                }
            }
            .backgroundStyle(.back)
            .orientationChange { size, vertical in
                isVertical = vertical
            }
            .onAppear {
                withAnimation {
                    commonOpacity = 1
                }
            }
        } else {
            VStack(spacing: 0) {
                topPart()
                    .opacity(commonOpacity)

                Spacer()

                VinylView()
                    .matchedGeometryEffect(id: "cover", in: animation)
                    .scaleEffect(imageScale)
                    .offset(imageOffset)
                    .vinilGesture(imageOffset: $imageOffset, imageScale: $imageScale, imageOpacity: $imageOpacity, next: next, prev: prev) {
                        close()
                    }

                Spacer()

                verticalPart()
                    .opacity(commonOpacity)
                    .orientationChange { size, vertical in
                        if isVertical != vertical {
                            if isVertical == nil {
                                withAnimation {
                                    isVertical = vertical
                                }
                            } else {
                                isVertical = vertical
                            }
                        }
                    }
            }
            .backgroundStyle(.back)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        commonOpacity = 1
                    }
                }
            }
        }
    }
    
    func close() {
        //withAnimation {
            currentFrame = lastCurrentFrame
        //}
    }
    
    func topPart() -> some View {
        HStack(spacing: 0) {
            Image(systemName: "xmark")
                .titleButtonImage(.leading)
                .hidden()
            
            Text(MediaPlayer.shared.currentPlaylistName ?? "")
                .font(trackFont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            
            Button {
                close()
            } label: {
                Image(systemName: "xmark")
                    .titleButtonImage(.trailing)
            }
            .frame(width: 44, alignment: .center)
        }
        .padding(.vertical, isVertical == false ? 16 : 0)
    }
    
    func verticalPart() -> some View {
        VStack(spacing: 0) {
            Text((variables.currentSong?.title ?? variables.currentSong?.name) ?? "")
                .lineLimit(2)
                .minimumScaleFactor(0.3)
                .multilineTextAlignment(.center)
                .font(mcTrackFont)
                .frame(minHeight: 22, maxHeight: 42)
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
                    prev()
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
                    next()
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
            .padding(.bottom, isVertical == false ? 16 : 35)
            
            if isVertical == false {
                Spacer()
            }
        }
    }
    
    func prev() {
        withAnimation(.easeInOut(duration: 0.2)) {
            imageScale = 0.75
            imageOpacity = 0.35
            imageOffset = CGSize(width: UIScreen.getSize().width, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            MediaPlayer.shared.prevFile()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            imageOffset = CGSize(width: -UIScreen.getSize().width, height: 0)
            withAnimation(.easeInOut(duration: 0.2)) {
                imageScale = 0.85
                imageOpacity = 1
                imageOffset = CGSize(width: 0, height: 0)
            }
        }
    }
    
    func next() {
        withAnimation(.easeInOut(duration: 0.2)) {
            imageScale = 0.75
            imageOpacity = 0.35
            imageOffset = CGSize(width: -UIScreen.getSize().width, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            MediaPlayer.shared.nextFile()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            imageOffset = CGSize(width: UIScreen.getSize().width, height: 0)
            withAnimation(.easeInOut(duration: 0.2)) {
                imageScale = 0.85
                imageOpacity = 1
                imageOffset = CGSize(width: 0, height: 0)
            }
        }
    }

}

struct VinilGesture: ViewModifier {

    var canSwitchSong: Bool = true
    
    @Binding var imageOffset: CGSize
    @Binding var imageScale: CGFloat
    @Binding var imageOpacity: CGFloat
    
    var onClose: () -> Void
    var next: () -> Void
    var prev: () -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged({ val in
                        let distX = val.location.x - val.startLocation.x
                        let disty = val.location.y - val.startLocation.y
                        
                        if canSwitchSong, abs(distX) > abs(disty) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                imageOffset = .init(width: distX, height: 0)
                                imageScale = getScale(x: distX)
                                imageOpacity = getOpacity(x: distX)
                            }
                        }
                    })
                    .onEnded({ val in
                        let distX = val.location.x - val.startLocation.x
                        let disty = val.location.y - val.startLocation.y
                        
                        if abs(distX) < abs(disty), disty > 0 {
                            onClose()
                        } else if canSwitchSong, abs(distX) > abs(disty) {
                            if abs(distX) < 100 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    imageOffset = .zero
                                    imageScale = 0.85
                                    imageOpacity = 1
                                }
                            } else {
                                if distX > 0 {
                                    prev()
                                } else {
                                    next()
                                }
                            }
                        }
                    })
            )
    }
    
    func getScale(x: CGFloat) -> CGFloat {
        
        let percent = (abs(x) / (UIScreen.getSize().width)) * 100
        let result =  0.85 - (0.85 * percent / 100)
        
        return result > 0.75 ? result : 0.75
    }

    func getOpacity(x: CGFloat) -> CGFloat {
        
        let percent = (abs(x) / (UIScreen.getSize().width)) * 100
        let result =  1 - (percent / 100)
        
        return result > 0.35 ? result : 0.35
    }

}

extension View {
    func vinilGesture(canSwitchSong: Bool = true, imageOffset: Binding<CGSize> = .constant(CGSize.zero), imageScale: Binding<CGFloat> = .constant(0), imageOpacity: Binding<CGFloat> = .constant(1), next: @escaping () -> Void = {}, prev: @escaping () -> Void = {}, onClose: @escaping () -> Void) -> some View {
        modifier(VinilGesture(canSwitchSong: canSwitchSong, imageOffset: imageOffset, imageScale: imageScale, imageOpacity: imageOpacity, onClose: onClose, next: next, prev: prev))
    }
}

//#Preview {
//    MusicControlView(currentFrame: .constant(4))
//}
