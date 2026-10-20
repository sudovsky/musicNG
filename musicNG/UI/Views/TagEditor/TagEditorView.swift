//
//  TagEditorView.swift
//  musicNG
//
//  Created by Max Sudovsky on 27.12.2024.
//

import SwiftUI

struct TagEditorView: View {

    @Environment(\.dismiss) var dismiss
    
    @Binding var playlist: Playlist?
    
    @State var files: [TagLineData] = []
    @State var mask = "%artist% - %title%.mp3"

    @State var importing = false
    
    @State var imageData: Data? = nil

    var body: some View {
        VStack(spacing: 0) {
            TitleView(backButtonVisible: .constant(true),
                      title: .constant("Tag editor"),
                      actionsVisible: .constant(true),
                      backButtonImage: Image(systemName: "xmark"),
                      actionImage: Image(systemName: "photo.badge.plus")) {
                importing.toggle()
            } backAction: {
                dismiss()
            }
            .padding(.trailing, 8)
            
            TextField("Mask", text: $mask)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            ScrollView {
                ForEach(files) { file in
                    TagEditorLineView(file: file)
                }
            }
            .padding(.vertical, 16)
            .imageSelection(importing: $importing) { data in
                imageData = data
            }

            HStack(spacing: 0) {
                Spacer()
                Button {
                    applyChecked(true)
                } label: {
                    Image(.checked)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.main)
                }
                Spacer()
                Button {
                    applyChecked(false)
                } label: {
                    Image(.unchecked)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.main)
                }
                Spacer()
                Button {
                    applyChecked()
                } label: {
                    Image(.checkInvert)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.main)
                }
                Spacer()
            }
            .frame(maxHeight: 28)
            .padding(.bottom, 16)
            
            Menu {
                Button("Apply all") {
                    saveChanges()
                    dismiss()
                }

                Divider()

                Button("Apply cover") {
                    updateImage()
                    dismiss()
                }
                
                Button("Apply artist") {
                    saveChanges(title: false, cover: false)
                    dismiss()
                }
                
                Button("Apply title") {
                    saveChanges(artist: false, cover: false)
                    dismiss()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .frame(maxHeight: 52)
                        .foregroundStyle(Color.main)
                    Text("Apply")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.back)
                }
            }
            .padding(.horizontal, 16)

        }
        .onAppear() {
            updateTags()
        }
        .onChange(of: mask) { _, newValue in
            updateTags()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    func applyChecked(_ checked: Bool? = nil) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let checked {
                for file in files {
                    file.isChecked = checked
                }
            } else {
                for file in files {
                    file.isChecked.toggle()
                }
            }
        }
    }
    
    func updateFiles() {
        files = playlist?.getDownloads(readMetadata: true).compactMap({ fileData in
            TagLineData(fileData: fileData, isChecked: files.first(where: { $0.fileData.path == fileData.path})?.isChecked ?? true)
        }) ?? []
    }
    
    func updateTags() {
        updateFiles()
        
        for file in files {
            file.fileData.artist = nil
            file.fileData.title = nil
            if let artist = file.fileData.getTagFromName(sourceTemplate: mask, tagName: "%artist%") {
                file.fileData.artist = artist
            }
            if let title = file.fileData.getTagFromName(sourceTemplate: mask, tagName: "%title%") {
                file.fileData.title = title
            }
        }
    }
    
    func saveChanges(artist: Bool = true, title: Bool = true, cover: Bool = true) {
        for file in files {
            if !file.isChecked { continue }
            
            let artistText = file.fileData.artist ?? "Unknown"
            let titleText = file.fileData.title ?? file.fileData.name
            
            editTags(fileData: file.fileData, artist: artist ? artistText : nil, title: title ? titleText : nil)
            
            guard let imageData = imageData, cover else {
                file.fileData.updateTags()
                continue
            }
            
            file.fileData.updateCover(imageData: imageData) { newData in
                file.fileData.saveData(data: newData) { _ in
                    file.fileData.updateTags()
                }
            }
        }
        
        Playlists.shared.reload()

        DispatchQueue.global().async {
            FilesMetaDB.save()
        }
    }
    
    func editTags(fileData: FileData, artist: String?, title: String?) {
        if !editableStandarts.contains(fileData.fileURL().pathExtension.uppercased()) {
            return
        }
        
        fileData.updateTextTags(title: title, artist: artist) { newData in
            fileData.saveData(data: newData)
            fileData.updateTags()
        }
    }

    func updateImage() {
        guard let imageData = imageData else { return }
        
        for file in files {
            if !file.isChecked { continue }
            
            file.fileData.updateCover(imageData: imageData) { newData in
                file.fileData.saveData(data: newData) { _ in
                    file.fileData.updateTags()
                }
            }
        }
        
        Playlists.shared.reload()
        
        DispatchQueue.global().async {
            FilesMetaDB.save()
        }
    }
    

}

#Preview {
    TagEditorView(playlist: .constant(nil))
}

class TagLineData: Identifiable, ObservableObject {
    var id = UUID()
    @Published var fileData = FileData()
    @Published var isChecked = true
    
    init(fileData: FileData = FileData(), isChecked: Bool = true) {
        self.fileData = fileData
        self.isChecked = isChecked
    }
    
    init() { }
}
