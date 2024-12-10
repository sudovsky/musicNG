//
//  TitleButtonImage.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.12.2024.
//

import SwiftUI

struct TitleButtonImage: ViewModifier {
    var padding: Edge.Set? = nil
    
    func body(content: Content) -> some View {
        return AnyView(content
            .font(.system(size: 25))
            .foregroundColor(.main)
            .padding(.bottom, 4)
            .padding(padding ?? .leading, padding == nil ? 0 : 8))
    }
}

extension View {
    func titleButtonImage(_ padding: Edge.Set? = nil) -> some View {
        modifier(TitleButtonImage(padding: padding))
    }
}
