//
//  RemoteListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteListView: View {
    
    @Binding var files: [FileData]
    
    @Binding var playlistSelection: Bool
    @Binding var filesToSave: [FileData]
    @Binding var readyToDownload: Bool

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
                    RemoteViewFileLine(file: file, playlistSelection: $playlistSelection, filesToSave: $filesToSave, readyToDownload: $readyToDownload) { selectedFile in
                        onChange?(selectedFile)
                    }
                }
                
            }
        }
        .padding(.vertical, 16)
    }
    
}

#Preview {
    RemoteListView(files: .constant([]), playlistSelection: .constant(false), filesToSave: .constant([]), readyToDownload: .constant(false))
}
