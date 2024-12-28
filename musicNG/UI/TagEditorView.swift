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

    var body: some View {
        VStack(spacing: 0) {
            TitleView(backButtonVisible: .constant(true),
                      title: .constant("Редактор mp3"),
                      actionsVisible: .constant(true),
                      backButtonImage: Image(.close),
                      actionImage: Image(systemName: "photo.badge.plus")) {
                importing.toggle()
            } backAction: {
                dismiss()
            }
            .padding(.trailing, 8)
            
            TextField("Маска", text: $mask)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            ScrollView {
                ForEach(files) { file in
                    TagEditorLineView(file: file)
                }
            }
            .padding(.vertical, 16)

            ImageSelectionView(importing: $importing, onGetImage: updateImage(imageData:))

            HStack(spacing: 0) {
                Spacer()
                Button {
                    applyChecked(true)
                } label: {
                    Image(.checked)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                Button {
                    applyChecked(false)
                } label: {
                    Image(.unchecked)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                Button {
                    applyChecked()
                } label: {
                    Image(.checkInvert)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
            }
            .frame(maxHeight: 28)
            .padding(.bottom, 16)
            
            Button {
                saveChanges()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                        .frame(maxHeight: 52)
                        .foregroundStyle(Color.main)
                    Text("Сохранить")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.back)
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(GrowingButton())

        }
        .onAppear() {
            updateTags()
        }
        .onChange(of: mask) { newValue in
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
            if let artist = file.fileData.getTagFromName(sourceTemplate: mask.lowercased(), tagName: "%artist%")?.capitalized {
                file.fileData.artist = artist
            }
            if let title = file.fileData.getTagFromName(sourceTemplate: mask.lowercased(), tagName: "%title%")?.capitalized {
                file.fileData.title = title
            }
        }
    }
    
    func saveChanges() {
        for file in files {
            if !file.isChecked { continue }
            editTags(fileData: file.fileData, artist: file.fileData.artist ?? "Unknown", title: file.fileData.title ?? file.fileData.name)
        }
        
        DispatchQueue.global().async {
            FilesMetaDB.save()
        }
    }
    
    func editTags(fileData: FileData, artist: String, title: String) {
        if fileData.fileURL().pathExtension.lowercased() != "mp3" {
            return
        }
        
        fileData.updateTextTags(title: title, artist: artist) { newData in
            fileData.saveData(data: newData)
            fileData.updateTags()
        }
    }

    func updateImage(imageData: Data) {
        for file in files {
            file.fileData.updateCover(imageData: imageData) { newData in
                file.fileData.saveData(data: newData)
                file.fileData.updateTags()
            }
        }
        
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
