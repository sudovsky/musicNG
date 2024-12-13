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
            TitleView(backButtonVisible: true,
                      actionImage: Image(systemName: "network"),
                      secondActionImage: Image(.plus),
                      title: playlist.name) {
                print(1);
            } secondAction: {
                print(2)
            }
            
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(fileList) { file in
                        SongTile(artistVisible: file.artist != nil, image: nil, artist: file.artist ?? "", track: file.name, shadow: true, gradient: true)
                    }
                    Color(.back)
                }.padding(16)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if fileList.isEmpty {
                fileList = playlist.getDownloads()
            }
        }
    }
}

#Preview {
    SongListView(playlist: Playlist())
}
