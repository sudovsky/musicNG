//
//  CurrentSongView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct CurrentSongView: View {
    
    @Binding var currentFrame: Int
    @Binding var lastCurrentFrame: Int

    var animation: Namespace.ID

    @ObservedObject var variables = Variables.shared

    @State private var blur: CGFloat = 16

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if currentFrame != 4 {
                    (variables.currentSong?.cover?.image() ?? Image(.no))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .matchedGeometryEffect(id: "cover", in: animation)
                        .frame(width: 58, height: 58)
                        .padding(.leading, 16)
                        .padding(.trailing, 12)
                } else {
                    Color.back
                        .frame(width: 58, height: 58)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .padding(.leading, 16)
                        .padding(.trailing, 12)
                }
                
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
            Divider()
        }
        .blur(radius: blur)
        .onAppear() {
            withAnimation(.easeOut.speed(1.8)) {
                blur = 0
            }
        }
        .onTapGesture {
            lastCurrentFrame = currentFrame
            currentFrame = 4
        }
    }
}

//#Preview {
//    CurrentSongView(currentFrame: .constant(1), lastCurrentFrame: .constant(1))
//}
