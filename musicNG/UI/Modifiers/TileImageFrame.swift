//
//  TileImageFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct TileImageFrame: ViewModifier {
    var destination: SongTile.SongTileDestination = .song
    
    func body(content: Content) -> some View {
        switch destination {
        case .playlist:
            return AnyView(content
                .frame(width: UIScreen.getSize().width / 2 - 30, height: UIScreen.getSize().width / 2 - 30))
        case .plSelection:
            return AnyView(content
                .frame(width: (UIScreen.getSize().width - 32) / 3 - 24,
                       height: (UIScreen.getSize().width - 32) / 3 - 24))
        default:
            return AnyView(content
                .frame(width: UIScreen.getSize().width / 2 - 24, height: UIScreen.getSize().width / 2 - 24))
        }
    }
}

extension View {
    func tileImageFrame(destination: SongTile.SongTileDestination = .song) -> some View {
        modifier(TileImageFrame(destination: destination))
    }
}
