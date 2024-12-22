//
//  PlayListSelection.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//

import SwiftUI

struct PlayListSelection: ViewModifier {
    @Binding var use: Bool
    var onSelect: (Playlist?, Bool) -> Void = { _,_ in }
    
    func body(content: Content) -> some View {
        if use {
            return AnyView(
                ZStack {
                    content
                        .blur(radius: 10)
                    PlaylistSelectionView(use: $use, onSelect: onSelect)
                }
            )
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func playListSelection(visible: Binding<Bool>, onSelect: @escaping (Playlist?, Bool) -> Void = { _,_ in }) -> some View {
        modifier(PlayListSelection(use: visible, onSelect: onSelect))
    }
}
