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
    
    var imageName: String? = nil
    var artist: String = "Unknown"
    var track: String = "Unknown"
    var shadow: Bool = true
    
    var body: some View {
        ZStack {
            getImageByName()
                .scaledToFill()
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
        .shadow(color: shadow ? commonShadowColor : .clear, radius: 5.4, x: 2.7, y: 5.5)
    }
    
    func getImageByName() -> Image {
        guard let imageName = imageName else {
            return Image("NoImage")
                .resizable()
        }
        
        return Image(imageName)
            .resizable()
    }
}

#Preview {
    SongTile()
}
