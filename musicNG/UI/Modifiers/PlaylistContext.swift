//
//  PlaylistContext.swift
//  musicNG
//
//  Created by Max Sudovsky on 23.12.2024.
//


import SwiftUI

struct PlaylistContext: ViewModifier {
    var playlist: Playlist
    var updateAction: () -> Void
    var action: (Int, Playlist) -> Void = { _,_ in }
    
    func body(content: Content) -> some View {
        return AnyView(content
            .contextMenu {
                Section("Drag and drop of elements is only available when sorting by \"Custom\"") {
                    
                    Button {
                        action(0, playlist)
                    } label: {
                        Label("Edit tags", systemImage: "square.and.pencil")
                    }
                    
                    Button {
                        action(1, playlist)
                    } label: {
                        Label("Rename playlist", systemImage: "pencil")
                    }
                    
                    Button {
                        action(2, playlist)
                    } label: {
                        Label("Change cover", systemImage: "photo")
                    }
                
                    Button {
                        action(3, playlist)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                
                Button(role: .destructive) {
                    action(4, playlist)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        )
        
    }
}

extension View {
    func playlistContext(playlist: Playlist, updateAction: @escaping () -> Void, action: @escaping (Int, Playlist) -> Void = { _,_ in }) -> some View {
        modifier(PlaylistContext(playlist: playlist, updateAction: updateAction, action: action))
    }
}
