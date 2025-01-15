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

    @State private var backButtonVisible: Bool = false
    @State private var title: String = "Плейлисты"
    @State private var actionsVisible: Bool = true

    @State private var bottomOpacity: CGFloat = 1

    @State private var showListSelection: Bool = false
    @State private var showRemote: Bool = false

    @State var showSettingsAlert = false
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
//                Spacer()
                prepareData()
            } else if currentFrame > 0 {
                TitleView(backButtonVisible: $backButtonVisible,
                          title: $title,
                          actionsVisible: $actionsVisible,
                          actionImage: Image(systemName: "network"),
                          secondActionImage: Image(systemName: "plus")) {
                    settingsOK() ? showRemote.toggle() : showSettingsAlert.toggle()
                } secondAction: {
                    showAlert.toggle()
                } backAction: {
                    playlistCoordinator.current = nil
                }
                
                ZStack {
                    
                    PlayListGrid()
                        .opacity(currentFrame == 1 ? 1 : 0)
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
        .okCancelMessage(showingAlert: $showSettingsAlert, title: .constant("Не заполнены настройки подключения"), subtitle: .constant("Перейти на страницу настроек?"), onOk: {
            withAnimation(Animation.easeOut.speed(2.5)) {
                currentFrame = 2
                title = "Настройки"
                backButtonVisible = false
                actionsVisible = false
            }
        })
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
        .onReceive(playlistCoordinator.$current) { plist in
            withAnimation {
                backButtonVisible = (plist?.id != nil) && currentFrame == 1
                title = plist?.name ?? "Плейлисты"
            }
        }
        .onReceive(playlistSelectionCoordinator.$needShowSelection) { plist in
            showListSelection = plist
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            bottomOpacity = newIsKeyboardVisible ? 0 : 1
        }
        .onReceive(playlists.$all) { lists in
            if !lists.isEmpty {
                currentFrame = 1
            }
        }
    }
    
    func prepareData() -> some View {
        Spacer()
    }
    
    func bottomView() -> some View {
        BottomView(page: $currentFrame) {
            withAnimation(Animation.easeOut.speed(1.8)) {
                if currentFrame == 2 {
                    currentFrame = 1
                    if let pname = playlistCoordinator.current?.name {
                        title = pname
                        backButtonVisible = true
                    } else {
                        title = "Плейлисты"
                        backButtonVisible = false
                    }
                    actionsVisible = true
                } else if playlistCoordinator.current != nil {
                    playlistCoordinator.current = nil
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
        .frame(maxHeight: bottomOpacity == 0 ? 0 : 44)
    }
    
    func settingsOK() -> Bool {
        if Settings.shared.username.isEmpty { return false}
        if Settings.shared.password.isEmpty { return false}
        if Settings.shared.address.isEmpty { return false}
        if Settings.shared.shareName.isEmpty { return false}
        
        return true
    }
}

#Preview {
    MainView()
}

