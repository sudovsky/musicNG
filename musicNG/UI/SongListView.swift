//
//  SongListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 12.12.2024.
//

import SwiftUI

struct SongListView: View {

    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewUpdater = ViewUpdater()
    @ObservedObject var plist = PlaylistCoordinator.shared

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
                    ForEach(fileList, id: \.self) { file in
                        Button {
                            Variables.shared.currentPlaylist = playlist
                            Variables.shared.songList = fileList
                            Variables.shared.currentSong = file
                            
                            let findx = fileList.firstIndex(where: { $0.id == file.id })
                            
                            PositionCoordinator.shared.position = 0
                            
                            MediaPlayer.shared.initPlayback(playlist: fileList, index: Int(findx ?? 0))
                        } label: {
                            SongTile(image: file.cover?.image() ?? noImage, artistVisible: file.artist != nil, artist: file.artist ?? "", track: file.title ?? file.name, shadow: true, gradient: true)
                                .songContext(file: file) { viewUpdater.reloadView() }
                        }
                        .buttonStyle(GrowingButton())
                    }
                    Color(.back)
                }.padding(16)
            }

            if plist.currentPlaylist == nil {
                Spacer()
                    .onAppear {
                        //withAnimation {
                            dismiss()
                        //}
                    }
            }

        }
        .navigationBarHidden(true)
        .onAppear {
            if fileList.isEmpty {
                fileList = playlist.getDownloads(readMetadata: true)
                PlaylistCoordinator.shared.currentPlaylist = playlist
            }
        }
        .onDisappear {
            if plist.currentPlaylist != nil {
                PlaylistCoordinator.shared.currentPlaylist = nil
            }
        }
    }
    
}

#Preview {
    SongListView(playlist: Playlist())
}
