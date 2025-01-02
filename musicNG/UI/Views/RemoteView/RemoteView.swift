//
//  RemoteView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteView: View {

    @Environment(\.dismiss) var dismiss
    
    @State var title: String = "Обзор"
    @State var searchStr: String = ""
    @State var currentPath = ""

    @State var files = [FileData]()

    let client = SMBClient()

    var body: some View {
        VStack(spacing: 0) {
            TitleView(backButtonVisible: .constant(true),
                      title: $title,
                      actionsVisible: .constant(true),
                      backButtonImage: nil,
                      actionImage: Image(.plus)) {
                
            } backAction: {
                withAnimation() {
                    currentPath == "" ? dismiss() : goBack()
                }
            }
            
            TextField("Поиск", text: $searchStr)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            RemoteListView(files: $files) { selectedFile in
                if selectedFile.isDirectory {
                    withAnimation {
                        title = selectedFile.name
                        currentPath = currentPath + "/" + selectedFile.name
                    }
                } else {
                    if let fileIndex = files.firstIndex(where: { $0.path == selectedFile.path }) {
                        
                        MediaPlayer.shared.initPlayback(playlist: files, index: fileIndex, client: client)
                    }
                }
            }
        }
        .onChange(of: currentPath) { newValue in
            client.listDirectory(path: currentPath) { error, data in
                files = data?.filter({!$0.isHidden}).sorted(by: {
                    ($0.isDirectory ? "0" : "1", $0.name) < ($1.isDirectory ? "0" : "1", $1.name)
                    
                }) ?? []
            }
        }
        .onAppear {
            client.updateClient()
            client.listDirectory(path: currentPath) { error, data in
                files = data?.filter({!$0.isHidden}).sorted(by: {
                    ($0.isDirectory ? "0" : "1", $0.name) < ($1.isDirectory ? "0" : "1", $1.name)
                    
                }) ?? []
            }
        }
    }
    
    func goBack() {
        let index = currentPath.lastIndex(where: {$0 == "/"})
        currentPath = String(currentPath[..<index!])
        
        if let index = currentPath.lastIndex(of: "/") {
            title = String(currentPath[index...].dropFirst())
        } else {
            title = "Обзор"
        }
    }
}

#Preview {
    RemoteView()
}
