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

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    let mars = fileList.getManyArrays()
                    ForEach(mars, id: \.self) { elem in
                        getButtons(elem: elem)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if fileList.isEmpty {
                fileList = playlist.getDownloads(readMetadata: true)
            }
        }
    }
    
    func getButtons(elem: [FileData]) -> some View {
        HStack(alignment: .center, spacing: 16) {
            if elem.count == 2 {
                getButton(file: elem[0])
                getButton(file: elem[1])
            } else if elem.count == 1 {
                getButton(file: elem[0])
                SongTile(image: noImage)
                    .opacity(0)
            }
        }
       .padding(.horizontal, 16)
    }
    
    func getButton(file: FileData) -> some View {
        Button {
            action(file: file)
        } label: {
            SongTile(image: file.cover?.image() ?? noImage, artistVisible: file.artist != nil, artist: file.artist ?? "", track: file.title ?? file.name, shadow: true, gradient: true)
        }
    }
    
    func action(file: FileData) {
        Variables.shared.currentPlaylist = playlist
        Variables.shared.songList = fileList
        Variables.shared.currentSong = file
        
        let findx = fileList.firstIndex(where: { $0.id == file.id })
        
        PositionCoordinator.shared.position = 0
        
        MediaPlayer.shared.initPlayback(playlist: fileList, index: Int(findx ?? 0))
    }
}

#Preview {
    SongListView(playlist: Playlist())
}
