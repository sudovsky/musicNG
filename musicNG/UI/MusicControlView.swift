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
            
            HStack(alignment: .center, spacing: 25) {
                
                Button {
                    
                } label: {
                    Image(systemName: "shuffle")
                        .foregroundStyle(.main)
                        .font(.system(size: 17))
                }
                .buttonStyle(GrowingButton())
                .shadowed()

                PlayControlButton(imageName: "backward.end.fill")
                    .frame(width: 44, height: 44)
                PlayControlButton(isBig: true)
                    .frame(width: 74, height: 74)
                PlayControlButton(imageName: "forward.end.fill")
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
            .padding(.bottom, 25)
            
            
        }
        .transition(.opacity.animation(.spring))
    }
}

#Preview {
    MusicControlView()
}
