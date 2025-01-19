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
    @State private var title: String = "Playlists".localized
    @State private var actionsVisible: Bool = true

    @State private var bottomOpacity: CGFloat = 1

    @State private var showListSelection: Bool = false
    @State private var showRemote: Bool = false

    @State var showSettingsAlert = false
    @State var showAlert = false
    @State var alertText: String = ""

    @State var alertTitle: String = "New playlist".localized
    @State var alertSubtitle: String = "Enter name".localized
    @State var alertPlaceholder: String = "Name".localized

    
    @State var index: Int = 0
    @State var items : [(title:String, text:String, image: Image?, buttonTitle: String)] = []

    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        VStack(spacing: 0) {
            if currentFrame == 0 {
//                Spacer()
                prepareData()
            } else if currentFrame == 3 {
                onboarding()
                    .transition(.opacity)
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
            
            if currentFrame != 0, currentFrame != 3 {
                bottomView()
            }
        }
        .background {
            Color.back
        }
        .okCancelMessage(showingAlert: $showSettingsAlert, title: .constant("Connection settings are not filled in"), subtitle: .constant("Go to the settings page?"), onOk: {
            withAnimation(Animation.easeOut.speed(2.5)) {
                currentFrame = 2
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
        .navigationBarHidden(true)
        .onReceive(playlistCoordinator.$current) { plist in
            withAnimation {
                backButtonVisible = (plist?.id != nil) && currentFrame == 1
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
                withAnimation {
                    currentFrame = 3
                }
                return
            }
            
            //if !lists.isEmpty {
                currentFrame = 1
            //}
        }
    }
//    //Welcome!
//    
//    Thank you for installing the app! I hope you enjoy it!
//        
//        Now I'll tell you how to add music
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
                     Image(.browse),
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
                        withAnimation {
                            currentFrame = 1
                        }
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
                if currentFrame == 2 {
                    currentFrame = 1
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
            if currentFrame == 2 { return }
            
            withAnimation(Animation.easeOut.speed(2.5)) {
                currentFrame = 2
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

