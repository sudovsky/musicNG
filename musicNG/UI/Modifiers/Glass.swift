//
//  Glass.swift
//  musicNG
//
//  Created by Max Sudovsky on 25.09.2025.
//

import SwiftUI

struct Glassed: ViewModifier {
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            return AnyView(content
                .glassEffect())
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func glassed() -> some View {
        modifier(Glassed())
    }
}
