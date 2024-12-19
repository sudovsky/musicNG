//
//  PlayListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct PlayListView: View {

    @ObservedObject var variables = Variables.shared
    @ObservedObject var playlistCoordinator = PlaylistCoordinator.shared
    
    @State private var showingDetail: Bool = false
    @State private var currentFrame: Int = 0
    @State private var playlists: [Playlist] = []

    @State private var backButtonVisible: Bool = false
    @State private var title: String = "Плейлисты"
    @State private var actionsVisible: Bool = true

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        VStack(spacing: 0) {
            if currentFrame == 0 {
                Spacer()
                prepareData()
            } else if currentFrame > 0 {
                TitleView(backButtonVisible: $backButtonVisible,
                          title: $title,
                          actionsVisible: $actionsVisible,
                          actionImage: Image(systemName: "network"),
                          secondActionImage: Image(.plus)) {
                    print(1);
                } secondAction: {
                    print(2)
                } backAction: {
                    playlistCoordinator.currentPlaylist = nil
                }
                
                ZStack {
                    PlayListGrid(playlists: playlists)
                    SettingsView()
                        .opacity(currentFrame == 2 ? 1 : 0)
                }

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
        .onReceive(playlistCoordinator.$currentPlaylist) { plist in
            withAnimation {
                backButtonVisible = (plist?.id != nil) && currentFrame == 1
            }
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
        BottomView(page: $currentFrame) {
            withAnimation(Animation.easeOut.speed(1.8)) {
                if currentFrame == 2 {
                    currentFrame = 1
                    if let pname = playlistCoordinator.currentPlaylist?.name {
                        title = pname
                        backButtonVisible = true
                    } else {
                        title = "Плейлисты"
                        backButtonVisible = false
                    }
                    actionsVisible = true
                } else if playlistCoordinator.currentPlaylist != nil {
                    playlistCoordinator.currentPlaylist = nil
                    title = "Плейлисты"
                }
            }
        } saction: {
            if currentFrame == 2 { return }
            
            withAnimation(Animation.easeOut.speed(2.5)) {
                currentFrame = 2
                title = "Настройки"
                backButtonVisible = false
                actionsVisible = false
            }
        }
    }
    
}

#Preview {
    PlayListView()
}

