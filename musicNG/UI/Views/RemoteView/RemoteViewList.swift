//
//  RemoteListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteListView: View {
    
    @Binding var files: [FileData]
    
    var onChange: ((FileData) -> Void)? = nil
    
    var body: some View {
        ScrollView {
            ForEach(files) { file in
                if file.isDirectory {
                    Button {
                        onChange?(file)
                    } label: {
                        RemoteViewDirectoryLine(name: file.name)
                    }
                } else {
                    Button {
                        onChange?(file)
                    } label: {
                        RemoteViewFileLine(title: file.title ?? file.name, artist: file.artist, image: file.cover)
                    }
                }
                
            }
        }
        .padding(.vertical, 16)
    }
    
}

#Preview {
    RemoteListView(files: .constant([]))
}
