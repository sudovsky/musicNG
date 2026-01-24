//
//  Glass.swift
//  musicNG
//
//  Created by Max Sudovsky on 25.09.2025.
//

import SwiftUI

struct Glassed: ViewModifier {
    
    var isClear: Bool = false
    var cornerRadius: CGFloat? = nil
    var tintColor: Color? = nil

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            let glass: Glass
            
            if let tintColor = tintColor {
                glass = isClear ? .clear.tint(tintColor) : .regular.tint(tintColor)
            } else {
                glass = isClear ? .clear : .regular
            }
            
            if let cornerRadius = cornerRadius {
                return AnyView(content
                    .glassEffect(glass, in: .rect(cornerRadius: cornerRadius)))
            } else {
                return AnyView(content
                    .glassEffect(glass))
            }
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func glassed(isClear: Bool = false, cornerRadius: CGFloat? = nil, tintColor: Color? = nil) -> some View {
        modifier(Glassed(isClear: isClear, cornerRadius: cornerRadius, tintColor: tintColor))
    }
}
