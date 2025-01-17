//
//  TileImageFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct TileImageFrame: ViewModifier {

    @StateObject private var orientation = OrientationCoordinator.shared

    var destination: SongTile.SongTileDestination = .song
    
    func body(content: Content) -> some View {
        content
            .frame(width: getSize().width,
                   height: getSize().height)
    }
    
    func getSize() -> CGSize {
        switch destination {
        case .playlist:
            let sz = orientation.vertical ? UIScreen.getSize().width / 2 - 30 : UIScreen.getSize().width / 3 - 22 - 16 - 16
            return CGSize(width: sz, height: sz)
        case .plSelection:
            let sz = orientation.vertical ? (UIScreen.getSize().width - 32) / 3 - 24 : (UIScreen.getSize().width - 32) / 3 - 24 - 24
            return CGSize(width: sz, height: sz)
        default:
            let sz = orientation.vertical ? UIScreen.getSize().width / 2 - 24 : UIScreen.getSize().width / 3 - 22 - 16 - 16
            return CGSize(width: sz, height: sz)
        }
    }
}

extension View {
    func tileImageFrame(destination: SongTile.SongTileDestination = .song) -> some View {
        modifier(TileImageFrame(destination: destination))
    }
}
