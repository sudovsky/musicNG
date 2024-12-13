//
//  PlayListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct PlayListView: View {

    @ObservedObject var variables = Variables.shared
    
    @State private var showingDetail: Bool = false
    @State private var currentFrame: Int = 0
    @State private var playlists: [Playlist] = []
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        VStack(spacing: 0) {
            if currentFrame == 0 {
                Spacer()
                prepareData()
            } else if currentFrame == 1 {
                NavigationView {
                    plView()
                }
            } else if currentFrame == 2 {
                TitleView(backButtonVisible: false,
                          title: "Настройки")
                
                Spacer()
                
            }
            if variables.currentSong != nil {
                CurrentSongView()
            }
            bottomView()
        }
        .background {
            Color.back
        }
        .navigationBarHidden(true)
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                withAnimation(.easeOut.speed(1.8)) {
//                    variables.currentSong = FileData()
//                }
//            }
        }
    }
    
    func prepareData() -> some View {
        Spacer()
            .onAppear {
                if !playlists.isEmpty { return }
                
                FilesMetaDB.restore()
                
                let path = FileManager.playlistsSettings
                
                playlists = load(path) ?? [Playlist(), Playlist(), Playlist()] as! [Playlist]
                
                for playlist in playlists {
                    playlist.updateDownloads()
                }
                
                currentFrame = 1
            }
    }
    
    func bottomView() -> some View {
        BottomView {
            currentFrame = 1
        } saction: {
            currentFrame = 2
        }
    }
    
    func plView() -> some View {
        return VStack(spacing: 0) {
            TitleView(backButtonVisible: false,
                      actionImage: Image(systemName: "network"),
                      secondActionImage: Image(.plus),
                      title: "Плейлисты") {
                print(1);
            } secondAction: {
                print(2)
            }

            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(playlists) { playlist in
                        NavigationLink {
                            SongListView(playlist: playlist)
                        } label: {
                            PlaylistTile(playlist: playlist)
                        }
                    }
                    Color(.back)
                }.padding(16)
            }

        }
    }
}

#Preview {
    PlayListView()
}

