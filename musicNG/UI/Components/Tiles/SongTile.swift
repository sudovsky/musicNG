//
//  SongTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 30.10.2024.
//

import SwiftUI
import Extensions

struct SongTile: View {
    
    enum SongTileDestination {
        case song
        case playlist
        case plSelection
    }
    
    var image: Image
    var artistVisible = true
    
    var artist: String = "Unknown Artist".localized
    var track: String = "Unknown Title".localized
    var shadow: Bool = true
    var gradient: Bool = true
    var destination: SongTileDestination = .song
    /// Если задан, в правом нижнем углу показывается эквалайзер,
    /// когда текущий трек — этот (.song) или из этого плейлиста (.playlist).
    var nowPlaying: NowPlayingIndicator.Target? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: commonCornerRadius, height: commonCornerRadius))
                .foregroundStyle(.clear)
                .background(content: {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                })
                .aspectRatio(contentMode: .fill)
            if gradient {
                LinearGradient(colors: [commonGradientColor, .clear], startPoint: UnitPoint.bottom, endPoint: UnitPoint.top)
            }
            VStack(spacing: 0) {
                Spacer()
                OutlinedText(text: track, width: 1, color: commonTextBorderColor)
                    .font(trackFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal], 8)
                    .padding([.bottom], artistVisible ? 0 : 6)
                    .foregroundStyle(comonTextColor)
                    .multilineTextAlignment(.leading)
                
                if artistVisible {
                    OutlinedText(text: artist, width: 1, color: commonTextBorderColor)
                        .font(artistFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal], 8)
                        .padding([.bottom], 6)
                        .foregroundStyle(comonTextColor)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .tileImageFrame(destination: destination)
        .overlay(alignment: .topTrailing) {
            if let nowPlaying {
                NowPlayingIndicator(target: nowPlaying)
                    .frame(width: 24, height: 24)
                    .padding(12)
            }
        }
        .cornerRadius(commonCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: commonCornerRadius)
                .stroke(commonBorderColor, lineWidth: commonBorderWidth)
        )
    }
    
}

#Preview {
    SongTile(image: noImage)
}
