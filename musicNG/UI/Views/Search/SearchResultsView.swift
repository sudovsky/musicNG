//
//  SearchResultsView.swift
//  musicNG
//
//  Created by Max Sudovsky on 25.01.2026.
//

import SwiftUI

struct SearchResultsView: View {
    
    @StateObject private var orientationCoordinator = OrientationCoordinator.shared

    let vcolumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    let hcolumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @Binding var songs: [FileData]

    var body: some View {
        LazyVGrid(columns: orientationCoordinator.vertical ? vcolumns : hcolumns, alignment: .center, spacing: 16) {
            ReorderableForEach($songs, allowReordering: .constant(false)) { file, isDragged in
                Button {
                    
                    Variables.shared.currentSong = file
                    
                    let findx = songs.firstIndex(where: { $0.id == file.id })
                    
                    PositionCoordinator.shared.position = 0
                    
                    MediaPlayer.shared.initPlayback(playlist: songs, index: Int(findx ?? 0), playlistName: "Search")
                } label: {
                    SongTile(image: file.cover?.image() ?? noImage, artistVisible: file.artist != nil, artist: file.artist ?? "", track: file.title ?? file.name, shadow: true, gradient: true)
                }
                .buttonStyle(GrowingButton())
                .overlay(isDragged ? Color.back.opacity(0.6) : Color.clear)
            }
            Color(.back)
        }
        .padding([.horizontal, .top], 16)
        .padding([.bottom], 14)
    }
}

#Preview {
    SearchResultsView(songs: .constant([]))
}
