//
//  ContentMargin26.swift
//  musicNG
//
//  Created by Max Sudovsky on 01.10.2025.
//

import SwiftUI

struct ContentMargin26: ViewModifier {
    
    var edges: Edge.Set = .bottom
    var length: CGFloat? = nil
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            return content
                .contentMargins(edges, length, for: .scrollContent)
        } else {
            return content
        }
    }
}

extension View {
    func contentMargin26(edges: Edge.Set = .bottom, _ length: CGFloat? = nil) -> some View {
        modifier(ContentMargin26(edges: edges, length: length))
    }
}
