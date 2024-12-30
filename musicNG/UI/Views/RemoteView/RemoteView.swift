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
    
    @State var files = [FileData]()

    let client = SMBClient()

    var body: some View {
        VStack(spacing: 0) {
            TitleView(backButtonVisible: .constant(true),
                      title: $title,
                      actionsVisible: .constant(true),
                      backButtonImage: Image(.close),
                      actionImage: Image(.plus)) {
                
            } backAction: {
                dismiss()
            }
            
            TextField("Поиск", text: $searchStr)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            RemoteListView(files: $files)
        }
        .onAppear {
            client.updateClient()
            client.listDirectory(path: "") { error, data in
                files = data?.filter({!$0.isHidden}).sorted(by: {
                    ($0.isDirectory ? "0" : "1", $0.name) < ($1.isDirectory ? "0" : "1", $1.name)
                    
                }) ?? []
            }
        }
    }
}

#Preview {
    RemoteView()
}
