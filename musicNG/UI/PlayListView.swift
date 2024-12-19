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
                TitleView(backButtonVisible: false,
                          actionImage: Image(systemName: "network"),
                          secondActionImage: Image(.plus),
                          title: "Плейлисты") {
                    print(1);
                } secondAction: {
                    print(2)
                }
                
                PlayListGrid(playlists: playlists)

            } else if currentFrame == 2 {
                TitleView(backButtonVisible: false,
                          title: "Настройки")
                
                Spacer()
                
            }
            if variables.currentSong != nil {
                CurrentSongView()
            }
            
            if currentFrame != 0 {
                bottomView()
            }
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
                
                let path = FileManager.playlistsSettings
                
                let plsts = load(path) ?? [Playlist(), Playlist(), Playlist()] as! [Playlist]
                
                plsts.updatedPlaylists { newLists in
                    for playlist in newLists {
                        playlist.updateDownloads()
                        playlist.updateCover()
                    }
                    
                    playlists = newLists
                    currentFrame = 1
                }
            }
    }
    
    func bottomView() -> some View {
        BottomView {
            currentFrame = 1
        } saction: {
            currentFrame = 2
        }
    }
    
}

#Preview {
    PlayListView()
}

