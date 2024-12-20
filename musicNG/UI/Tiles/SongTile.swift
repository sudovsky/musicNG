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
//            image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: UIScreen.getSize().width / 2 - 24, height: UIScreen.getSize().width / 2 - 24)
//                .clipped()
            if gradient {
                LinearGradient(colors: [commonGradientColor, .clear], startPoint: UnitPoint.bottom, endPoint: UnitPoint.top)
            }
            VStack(spacing: 0) {
                Spacer()
                Text(track)
                    .font(trackFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal], 10)
                    .padding([.bottom], artistVisible ? 0 : 10)
                    .foregroundStyle(comonTextColor)
                    .shadow(color: .main, radius: 1)
                    .multilineTextAlignment(.leading)
                
                if artistVisible {
                    Text(artist)
                        .font(artistFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.horizontal, .bottom], 10)
                        .foregroundStyle(comonTextColor)
                        .shadow(color: .main, radius: 1)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .aspectRatio(contentMode: .fit)
        .tileImageFrame()
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
