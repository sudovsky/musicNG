//
//  TileImageFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct TileImageFrame: ViewModifier {
    func body(content: Content) -> some View {
        return AnyView(content
            .frame(width: UIScreen.getSize().width / 2 - 24, height: UIScreen.getSize().width / 2 - 24)
)
    }
}

extension View {
    func tileImageFrame() -> some View {
        modifier(TileImageFrame())
    }
}
