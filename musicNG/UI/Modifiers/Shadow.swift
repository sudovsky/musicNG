//
//  Shadow.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import SwiftUI

struct Shadowed: ViewModifier {
    var use = true
    
    func body(content: Content) -> some View {
        if use {
            return AnyView(content
                .shadow(color: commonShadowColor, radius: 5.4, x: 2.7, y: 5.5))
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func shadowed(use: Bool = true) -> some View {
        modifier(Shadowed(use: use))
    }
}
