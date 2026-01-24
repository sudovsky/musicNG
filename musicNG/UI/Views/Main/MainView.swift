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
    @StateObject private var orientationCoordinator = OrientationCoordinator.shared

    @State private var showingDetail: Bool = false
    @State private var currentFrame: CurrentFrameID = .empty
    @State private var lastCurrentFrame: CurrentFrameID = .empty

    @State private var backButtonVisible: Bool = false
    @State private var title: String = "Playlists".localized
    @State private var actionsVisible: Bool = true

    @State private var bottomOpacity: CGFloat = 1

    @State private var showListSelection: Bool = false
    @State private var showRemote: Bool = false
    @State private var showSearch: Bool = false

    @State var showSettingsAlert = false
    @State var showAlert = false
    @State var alertText: String = ""

    @State var songRestored = false

    @State var alertTitle: String = "New playlist".localized
    @State var alertSubtitle: String = "Enter name".localized
    @State var alertPlaceholder: String = "Name".localized

    @Namespace private var animation

    @State var index: Int = 0
    @State var items : [(title:String, text:String, image: Image?, buttonTitle: String)] = []

    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if currentFrame == .empty {
                    //                Spacer()
                    prepareData()
                } else if currentFrame == .onboarding {
                    onboarding()
                        .transition(.opacity)
                } else if currentFrame.rawValue > 0 {
                    if currentFrame == .playlist || currentFrame == .settings || currentFrame == .musicControl, !ios26 {
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
                        .opacity(currentFrame == .musicControl ? 0 : 1)
                        .transition(.opacity)
                    }
                    
                    ZStack {
                        
                        PlayListGrid()
                            .opacity(currentFrame == .playlist ? 1 : 0)
                            .transition(.opacity)
                        SettingsView()
                            .opacity(currentFrame == .settings ? 1 : 0)
                            .transition(.opacity)
                        
                    }
                    
                }
                
                if !ios26, variables.currentSong != nil, currentFrame == .playlist || currentFrame == .settings || currentFrame == .musicControl {
                    CurrentSongView(currentFrame: $currentFrame, lastCurrentFrame: $lastCurrentFrame, animation: animation)
                        .opacity(currentFrame == .musicControl ? 0 : 1)
                        .transition(.opacity)
                }
                
                if !ios26, currentFrame != .empty, currentFrame != .onboarding {
                    bottomView()
                        .opacity(currentFrame == .musicControl ? 0 : 1)
                        .transition(.opacity)
                }

            }

            if ios26 {
                VStack {
                    LinearGradient(colors: [.back, .back, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: orientationCoordinator.vertical ? 80 : 40)
                        .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    Spacer()
                }
            }
            
            if ios26, currentFrame == .playlist || currentFrame == .settings || currentFrame == .search {
                if #available(iOS 26.0, *) {
                    VStack(spacing: 0) {
                        TitleView26(backButtonVisible: $backButtonVisible,
                                    title: $title, currentFrame: $currentFrame) {
                            showAlert.toggle()
                        } networkAction: {
                            settingsOK() ? showRemote.toggle() : showSettingsAlert.toggle()
                        }
                        Spacer()
                    }
                }
            }
            
            if ios26 {
                VStack {
                    Spacer()
                    
                    if variables.currentSong != nil, currentFrame == .playlist || currentFrame == .settings || currentFrame == .musicControl {
                        CurrentSongView(currentFrame: $currentFrame, lastCurrentFrame: $lastCurrentFrame, animation: animation)
                            .opacity(currentFrame == .musicControl || showAlert ? 0 : 1)
                            .transition(.opacity)
                            .padding(.horizontal, 8)
                            //.padding(.bottom, 56)
                    }
                }
            }
            
            if currentFrame == .musicControl {
                MusicControlView(currentFrame: $currentFrame, lastCurrentFrame: lastCurrentFrame, animation: animation)
                    .transition(.opacity)
            }
            
            if currentFrame == .search {
                SearchView()
                    .transition(.opacity)
            }

        }
        .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentFrame)
        .background {
            Color.back
        }
        .okCancelMessage(showingAlert: $showSettingsAlert, title: .constant("Connection settings are not filled in".localized), subtitle: .constant("Go to the settings page?".localized), onOk: {
            currentFrame = .settings
            withAnimation(Animation.easeOut.speed(2.5)) {
                title = "Settings".localized
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
        .fullScreenCover(isPresented: $showSearch) {
            SearchView()
        }
        .navigationBarHidden(true)
        .onReceive(playlistCoordinator.$current) { plist in
            withAnimation {
                backButtonVisible = (plist?.id != nil) && currentFrame == .playlist
                title = plist?.name ?? "Playlists".localized
            }
        }
        .onReceive(playlistSelectionCoordinator.$needShowSelection) { plist in
            showListSelection = plist
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            bottomOpacity = newIsKeyboardVisible ? 0 : 1
        }
        .onReceive(playlists.$all) { lists in
            if !Settings.shared.isAppInitiated {
//                withAnimation {
                currentFrame = .onboarding
//                }
                return
            }
            
            if currentFrame == .empty {
                currentFrame = .playlist
            }
            getLastSong(lists: lists)
        }
    }
    
    func getLastSong(lists: [Playlist]) {
        
        guard !songRestored, lists.count > 0, let lastPLName = Settings.shared.lastPlaylistName, let lastSongName = Settings.shared.lastSongName else {
            return
        }
        
        songRestored = true
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let foundPL = lists.first(where: { $0.name == lastPLName }) else { return }
            
            let fileList = foundPL.getDownloads(readMetadata: true)
            
            guard let foundSong = fileList.first(where: { $0.name == lastSongName }) else { return }
            
            let findx = fileList.firstIndex(where: { $0.id == foundSong.id })
            
            DispatchQueue.main.async {
                PositionCoordinator.shared.position = 0
            }
            
            MediaPlayer.shared.initPlayback(playlist: fileList, index: Int(findx ?? 0), playlistName: foundPL.name, autostart: false) {
                
                if let pTime = Settings.shared.lastSongPosition {
                    MediaPlayer.shared.seek(positionTime: pTime)
                    MediaPlayer.shared.updateCurrentPos()
                }
            }
            
            DispatchQueue.main.async {
                variables.currentSong = foundSong
            }
        }
        
    }
    
    func prepareData() -> some View {
        Spacer()
            .onAppear {
                items = [
                    ("Hi!".localized,
                     "onboarding_text_1".localized,
                     Image(.note2),
                     "Next".localized),
                    ("onboarding_title_1".localized,
                     "onboarding_text_2".localized,
                     Image(.share),
                     "Next".localized),
                    ("onboarding_title_2".localized,
                     "onboarding_text_3".localized,
                     Image(.files),
                     "Next".localized),
                    ("onboarding_title_3".localized,
                     "onboarding_text_4".localized,
                     Image(.files),
                     "Next".localized),
                    ("onboarding_title_4".localized,
                     "onboarding_text_5".localized,
                     Image(.menuEn),
                     "Got it!".localized)
                    ]
            }
    }
    
    func onboarding() -> some View {
        VStack(spacing: 0) {

            SwiftUIPagerView(index: $index, pages: self.items.identify { $0.title }) { size, item in
                
                OnboardingSheetView(title: item.model.title, text: item.model.text, image: item.model.image, buttonTitle: item.model.buttonTitle) {
                    if index < items.count - 1 {
                        withAnimation {
                            index += 1
                        }
                    } else {
                        Settings.shared.initiated()
                        //withAnimation {
                        currentFrame = .playlist
                        //}
                    }
                }
                .frame(width: size.width - 32, height: size.height - 32)
                .padding()
            }
            .transition(.scale.combined(with: .opacity))

        }
    
    }
    
    func bottomView() -> some View {
        BottomView(page: $currentFrame) {
            withAnimation(Animation.easeOut.speed(1.8)) {
                if currentFrame == .settings {
                    currentFrame = .playlist
                    if let pname = playlistCoordinator.current?.name {
                        title = pname
                        backButtonVisible = true
                    } else {
                        title = "Playlists".localized
                        backButtonVisible = false
                    }
                    actionsVisible = true
                } else if playlistCoordinator.current != nil {
                    playlistCoordinator.current = nil
                    title = "Playlists".localized
                }
                
                DispatchQueue.global().async {
                    Settings.shared.save()
                }
            }
        } saction: {
            if currentFrame == .settings { return }
            
            currentFrame = .settings
            withAnimation(Animation.easeOut.speed(2.5)) {
                title = "Settings".localized
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

