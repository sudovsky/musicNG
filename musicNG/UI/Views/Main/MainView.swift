//
//  PlayListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct MainView: View, KeyboardReadable {

    @ObservedObject var variables = Variables.shared
    @ObservedObject var playlistCoordinator = PlaylistCoordinator.shared
    @ObservedObject var playlistSelectionCoordinator = PlaylistSelectionCoordinator.shared
    @ObservedObject var playlists = Playlists.shared

    @State private var showingDetail: Bool = false
    @State private var currentFrame: Int = 0

    @State private var visiblePlaylist: Playlist? = nil
    @State private var backButtonVisible: Bool = false
    @State private var title: String = "Плейлисты"
    @State private var actionsVisible: Bool = true

    @State private var bottomOpacity: CGFloat = 1

    @State private var showListSelection: Bool = false
    @State private var showRemote: Bool = false

    @State var showAlert = false
    @State var alertText: String = ""

    @State var alertTitle: String = "Новый плейлист"
    @State var alertSubtitle: String = "Введите название"
    @State var alertPlaceholder: String = "Название"

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
                    showRemote.toggle()
                } secondAction: {
                    showAlert.toggle()
                } backAction: {
                    playlistCoordinator.currentPlaylist = nil
                }
                
                ZStack {
                    
                    PlayListGrid()
                        .opacity(visiblePlaylist == nil ? 1 : 0)
                        .scaleEffect(visiblePlaylist == nil ? 1 : 0.9)
                if visiblePlaylist != nil {
                    SongListView(playlist: $visiblePlaylist)
                        .transition(.move(edge: .trailing).combined(with: .opacity))                    }
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
        .alertFrame(showingAlert: $showAlert, text: $alertText, title: $alertTitle, subtitle: $alertSubtitle, placeholder: $alertPlaceholder, onDone: createPlaylist)
        .playListSelection(visible: $showListSelection) { pl, isNew in
            guard let fileToMove = PlaylistSelectionCoordinator.shared.fileToMove, let playlistFromMove = PlaylistSelectionCoordinator.shared.playlistFromMove else { return }
            
            moveFile(source: playlistFromMove, destination: pl, file: fileToMove)
            
            PlaylistSelectionCoordinator.shared.fileToMove = nil
            PlaylistSelectionCoordinator.shared.playlistFromMove = nil
            
        }
        .fullScreenCover(isPresented: $showRemote) {
            RemoteView()
        }
        .navigationBarHidden(true)
        .onReceive(playlistCoordinator.$currentPlaylist) { plist in
            withAnimation {
                backButtonVisible = (plist?.id != nil) && currentFrame == 1
                title = plist?.name ?? "Плейлисты"
                visiblePlaylist = plist
            }
        }
        .onReceive(playlistSelectionCoordinator.$needShowSelection) { plist in
            showListSelection = plist
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            bottomOpacity = newIsKeyboardVisible ? 0 : 1
        }
    }
    
    func prepareData() -> some View {
        Spacer()
            .onAppear {
                if !playlists.all.isEmpty { return }
                
                playlists.reload { _ in
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
                
                DispatchQueue.global().async {
                    Settings.shared.save()
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
        .opacity(bottomOpacity)
    }
    
}

#Preview {
    MainView()
}

