//
//  FilesMetaDBLine.swift
//  musicNG
//
//  Created by Max Sudovsky on 13.12.2024.
//

import SwiftUI

class FilesMetaDBLine: Codable {
    
    var id = UUID().uuidString
    var path = ""
    var title = ""
    var artist = ""
    var cover: UIImage? { loadCover() }
    var peaks: [Float]? = nil

    init() {}
    
    func saveCover(image: UIImage?) {
        let fileURL = FileManager.covers.appendingPathComponent(id).appendingPathExtension("jpg")
        do {
            if let data = image?.jpegData(compressionQuality: 1) {
                try data.write(to: fileURL, options: .atomic)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func loadCover() -> UIImage? {
        let fileURL = FileManager.covers.appendingPathComponent(id).appendingPathExtension("jpg")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func removeCover() {
        let fileURL = FileManager.covers.appendingPathComponent(id).appendingPathExtension("jpg")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error {
            print(error.localizedDescription)
            return
        }
    }
}

