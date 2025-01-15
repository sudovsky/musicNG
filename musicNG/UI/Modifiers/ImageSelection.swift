//
//  ImageSelection.swift
//  musicNG
//
//  Created by Max Sudovsky on 15.01.2025.
//

import SwiftUI
import ImagePickerView

struct ImageSelection: ViewModifier {
    
    @Binding var importing: Bool
    
    @State private var showingFileSelection = false
    @State private var isImagePickerViewPresented = false

    var onGetImage: ((Data) -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $showingFileSelection, allowedContentTypes: [.image]) { result in
                    switch result {
                    case .success(let file):
                        if file.startAccessingSecurityScopedResource(), let data = try? Data(contentsOf: file) {
                            file.stopAccessingSecurityScopedResource()
                            onGetImage?(data)
                        }
                    case .failure(let error): print(error.localizedDescription)
                    }
                }
                .confirmationDialog("Выбор изображения",
                                    isPresented: $importing) {
                    Button("Из галереи") { isImagePickerViewPresented = true }
                    Button("Из файлов") { showingFileSelection = true }
                    
                    Button("Cancel", role: .cancel) { }
                }
                .sheet(isPresented: $isImagePickerViewPresented) {
                    // filter default is .images; please DO NOT CHOOSE .videos
                    // selectionLimit default is 1; set to 0 to have unlimited selection
                    ImagePickerView(filter: .any(of: [.images, .livePhotos]), selectionLimit: 1, delegate: ImagePickerView.Delegate(isPresented: $isImagePickerViewPresented, didCancel: { (phPickerViewController) in
                        print("Did Cancel: \(phPickerViewController)")
                    }, didSelect: { (result) in
                        let phPickerViewController = result.picker
                        let images = result.images
                        print("Did Select images: \(images) from \(phPickerViewController)")
                        guard let imgData = images.first?.jpegData(compressionQuality: 1) else { return }
                        onGetImage?(imgData)
                    }, didFail: { (imagePickerError) in
                        let phPickerViewController = imagePickerError.picker
                        let error = imagePickerError.error
                        print("Did Fail with error: \(error) in \(phPickerViewController)")
                    }))
                }
    }
}

extension View {
    func imageSelection(importing: Binding<Bool>, onGetImage: ((Data) -> Void)?) -> some View {
        modifier(ImageSelection(importing: importing, onGetImage: onGetImage))
    }
}
