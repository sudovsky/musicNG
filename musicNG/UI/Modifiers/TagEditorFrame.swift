//
//  TagEditorFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 28.12.2024.
//

import SwiftUI

struct TagEditorFrame: ViewModifier {
    @Binding var playlist: Playlist?
    @Binding var isVisible: Bool
    
    func body(content: Content) -> some View {
        if playlist != nil {
            return AnyView(content
                .fullScreenCover(isPresented: $isVisible.animation()) {
                    TagEditorView(playlist: $playlist)
                }
            )
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func tagEditorFrame(for playlist: Binding<Playlist?>, isVisible: Binding<Bool>) -> some View {
        modifier(TagEditorFrame(playlist: playlist, isVisible: isVisible))
    }
}
