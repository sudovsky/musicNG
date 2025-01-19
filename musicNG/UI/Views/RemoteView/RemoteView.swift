//
//  RemoteView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteView: View {

    @Environment(\.dismiss) var dismiss
    
    @State var title: String = "Browse".localized
    @State var searchStr: String = ""
    @State var currentPath = ""

    @State var files = [FileData]()
    @State var filteredFiles = [FileData]()

    @State var playlistSelection: Bool = false
    @State var filesToSave = [FileData]()
    @State var readyToDownload = false
    @State var playlistToSave: Playlist? = nil
    @State private var needClearPlaylistName: Bool = false
    
    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            TitleView(backButtonVisible: .constant(true),
                      title: $title,
                      actionsVisible: .constant(true),
                      backButtonImage: nil,
                      actionImage: Image(systemName: "arrow.down.circle")) {
                getFilesForDownload()
            } backAction: {
                withAnimation() {
                    currentPath == "" ? dismiss() : goBack()
                }
            }
            
            TextField("Search", text: $searchStr)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .onChange(of: searchStr) { text in
                    if text.trim().isEmpty {
                        filteredFiles = files
                        return
                    }
                    filteredFiles = files.filter { $0.name.uppercased().contains(text.uppercased()) }
                }
            
            RemoteListView(files: $filteredFiles, playlistSelection: $playlistSelection, filesToSave: $filesToSave, readyToDownload: $readyToDownload, playlistToSave: $playlistToSave) { selectedFile in
                if selectedFile.isDirectory {
                    withAnimation {
                        title = selectedFile.name
                        currentPath = currentPath + "/" + selectedFile.name
                    }
                } else {
                    if let fileIndex = files.firstIndex(where: { $0.path == selectedFile.path }) {
                        
                        Variables.shared.currentSong = files[fileIndex]
                        
                        MediaPlayer.shared.initPlayback(playlist: files, index: fileIndex)
                    }
                }
            }
        }
        .okMessage(showingAlert: $showError, title: .constant("Connection error".localized), subtitle: $errorMessage, onOk: {
            errorMessage = nil
        })
        .onChange(of: currentPath) { newValue in
            listDirectory {
                UIApplication.shared.endEditing()
                searchStr = ""
            }
        }
        .onAppear {
            listDirectory()
        }
        .playListSelection(visible: $playlistSelection) { pl, isNew in
            guard let name = title.isEmpty ? filesToSave.first?.name : title else { return }
            
            if isNew {
                let list = Playlist()
                list.name = name
                list.sortKey = Playlists.shared.all.count
                Playlists.shared.all.append(list)
                Playlists.shared.save()
                
                _ = FileManager.default.urlForPlaylistSettings(name: list.name)
                
                playlistToSave = list
            } else {
                playlistToSave = pl
            }
            
            readyToDownload = true
        }
        .onChange(of: readyToDownload) { ready in
            guard ready, filesToSave.count > 0 else {
                readyToDownload = false
                return
            }
            readyToDownload = false
            startDownload()
        }
    }
    
    func listDirectory(onDone: @escaping () -> Void = {}) {
        Downloads.shared.client.listDirectory(path: currentPath) { error, data in
            if let error = error {
                errorMessage = error
                showError = true
            }
            
            files = data?.filter({!$0.isHidden}).sorted(by: {
                ($0.isDirectory ? "0" : "1", $0.name) < ($1.isDirectory ? "0" : "1", $1.name)
                
            }) ?? []
            filteredFiles = files
            onDone()
        }
    }
    
    func startDownload() {
        Downloads.append(filesToSave, listName: playlistToSave!.name)
        Downloads.startDownload()
        filesToSave = []
        
        if needClearPlaylistName {
            needClearPlaylistName = false
            playlistToSave = nil
        }
    }

    func getFilesForDownload() {
        filesToSave = files.filter { !$0.isDirectory }
        if filesToSave.count == 0 { return }
        
        needClearPlaylistName = true
        withAnimation {
            playlistSelection.toggle()
        }
    }
    
    func goBack() {
        let index = currentPath.lastIndex(where: {$0 == "/"})
        currentPath = String(currentPath[..<index!])
        
        if let index = currentPath.lastIndex(of: "/") {
            title = String(currentPath[index...].dropFirst())
        } else {
            title = "Browse".localized
        }
    }
}

#Preview {
    RemoteView()
}
