//
//  SongListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 12.12.2024.
//

import SwiftUI

struct SongListView: View {

    var playlist: Playlist = Playlist()
    @State var fileList: [FileData] = []

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(fileList) { file in
                        Button {
                            Variables.shared.currentPlaylist = playlist
                            Variables.shared.songList = fileList
                            Variables.shared.currentSong = file
                            
                            let findx = fileList.firstIndex(where: { $0.id == file.id })
                            
                            PositionCoordinator.shared.position = 0
                            
                            MediaPlayer.shared.initPlayback(playlist: fileList, index: Int(findx ?? 0))
                        } label: {
                            SongTile(image: file.cover?.image() ?? noImage, artistVisible: file.artist != nil, artist: file.artist ?? "", track: file.title ?? file.name, shadow: true, gradient: true)
                        }
                    }
                    Color(.back)
                }.padding(16)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if fileList.isEmpty {
                fileList = playlist.getDownloads(readMetadata: true)
            }
        }
    }
}

#Preview {
    SongListView(playlist: Playlist())
}
