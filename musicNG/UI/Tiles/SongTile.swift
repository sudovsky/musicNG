//
//  SongTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 30.10.2024.
//

import SwiftUI
import Extensions

struct SongTile: View {
    
    var image: Image
    var artistVisible = true
    
    var artist: String = "Unknown"
    var track: String = "Unknown"
    var shadow: Bool = true
    var gradient: Bool = true
    var dif: CGFloat = 0
    
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
                Text(track)
                    .font(trackFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal], 8)
                    .padding([.bottom], artistVisible ? 0 : 6)
                    .foregroundStyle(comonTextColor)
                    .shadow(color: .main, radius: 1)
                    .multilineTextAlignment(.leading)
                
                if artistVisible {
                    Text(artist)
                        .font(artistFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal], 8)
                        .padding([.bottom], 6)
                        .foregroundStyle(comonTextColor)
                        .shadow(color: .main, radius: 1)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .tileImageFrame(dif: dif)
        .cornerRadius(commonCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: commonCornerRadius)
                .stroke(commonBorderColor, lineWidth: commonBorderWidth)
        )
        .shadowed(use: shadow)
    }
    
}

#Preview {
    SongTile(image: noImage)
}
