//
//  TileImageFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct TileImageFrame: ViewModifier {
    var dif: CGFloat = 0
    
    func body(content: Content) -> some View {
        return AnyView(content
            .frame(width: UIScreen.getSize().width / 2 - 24 - dif, height: UIScreen.getSize().width / 2 - 24 - dif)
)
    }
}

extension View {
    func tileImageFrame(dif: CGFloat = 0) -> some View {
        modifier(TileImageFrame(dif: dif))
    }
}
