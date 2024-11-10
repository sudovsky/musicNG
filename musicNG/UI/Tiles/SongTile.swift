//
//  SongTile.swift
//  musicNG
//
//  Created by Max Sudovsky on 30.10.2024.
//

import SwiftUI
import Extensions

struct SongTile: View {
    
    @State var artistVisible = true
    
    var image: Image? = nil
    var artist: String = "Unknown"
    var track: String = "Unknown"
    var shadow: Bool = true
    
    var body: some View {
        ZStack {
            getImage()
                .aspectRatio(contentMode: .fill)
            LinearGradient(colors: [commonGradientColor, .clear], startPoint: UnitPoint.bottom, endPoint: UnitPoint.top)
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
        .cornerRadius(commonCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: commonCornerRadius)
                .stroke(commonBorderColor, lineWidth: commonBorderWidth)
        )
        .shadowed(use: shadow)
    }
    
    func getImage() -> Image {
        guard let image = image else {
            return Image("NoImage")
                .resizable()
        }
        
        return image
            .resizable()
    }
}

#Preview {
    SongTile()
}
