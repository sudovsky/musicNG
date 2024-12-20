//
//  FileData.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import SwiftUI

class FileData: Hashable, Codable, Identifiable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case customSortKey
        case createdDate
    }
    
    var id = UUID().uuidString
    var name = ""
    var path = ""
    var size: Int64? = nil
    var createdDate: Date = Date()
    var modifiedDate: Date? = nil
    var isDirectory = false
    var isHidden = false
    var title: String? = nil
    var artist: String? = nil
    var cover: Data? = nil
    var customSortKey = 0
    
    var peaks: [Float] { slowPeaks ?? fastPeaks }
    var fastPeaks = [Float]()
    var slowPeaks: [Float]? = nil

    var fileDownloaded: Bool { FileManager.default.fileExists(atPath: fileURL().path) }

    init() { }
    
    init(name: String, path: String, customSortKey: Int) {
        self.name = name
        self.path = path
        self.customSortKey = customSortKey
    }
    
    func readMetadata() {
        
        if let fdbl = FilesMetaDB.getDataForPath(path) {
            title = fdbl.title
            artist = fdbl.artist
            cover = fdbl.cover
            if let p = fdbl.peaks {
                slowPeaks = p
            }
            return
        }

        MediaPlayer.dataFromFile(file: self, updateDB: true, local: true) { t, a, c, p in
            self.title = t
            self.artist = a ?? ""
            self.cover = c
            if let p = p {
                self.slowPeaks = p
            }
        }
        
        if peaks.isEmpty {
            MediaPlayer.shared.readBuffer(fileURL(), notify: false) { fast, data in
                if fast {
                    self.fastPeaks = data
                    
                    if Variables.shared.currentSong?.id == self.id {
                        withAnimation {
                            Variables.shared.currentSong = self
                        }
                    }
                } else {
                    self.slowPeaks = data

                    if Variables.shared.currentSong?.id == self.id {
                        withAnimation {
                            Variables.shared.currentSong = self
                        }
                    }

                    if let dataLine = FilesMetaDB.data.first(where: {$0.path == self.path}) {
                        dataLine.peaks = data
                    }
                }
            }
        }
        
//
//        if async {
//            DispatchQueue.global().async {
//                for file in plist {
//                    if !file.isDirectory, file.title == nil, file.artist == nil {
//                        MediaPlayer.dataFromFile(file: file, updateDB: true) { t, a, c, p in
//                            file.title = t
//                            file.artist = a ?? ""
//                            file.cover = c
//                            if let p = p {
//                                file.slowPeaks = p
//                            }
//                        }
//                    }
//                }
//                DispatchQueue.main.async {
//                    readedData()
//                }
//            }
//            return
//        }
//        
//        for file in plist {
//            if !file.isDirectory, file.title == nil, file.artist == nil {
//                MediaPlayer.dataFromFile(file: file, updateDB: true) { t, a, c, p in
//                    file.title = t
//                    file.artist = a ?? ""
//                    file.cover = c
//                    if let p = p {
//                        file.slowPeaks = p
//                    }
//                }
//            }
//        }
    }

    func getData(completion: @escaping (Data?) -> Void = { _ in }) {
        if isDirectory {
            return
        }
        
        if fileDownloaded, let dat = try? Data(contentsOf: fileURL()) {
            completion(dat)
            return
        }

        //TODO: - dowload file
//        client.getFileData(path: path) { error, data in
//            guard let data = data else { return }
//            //self.saveData(data: data)
//            completion(data)
//        }
    }

    func fileURL(needCreate: Bool = false) -> URL {
        return FileManager.root.appendingPathComponent(path)
    }
    
    func updateTags(completion: @escaping () -> Void = {}) {
        if !isDirectory {
            FilesMetaDB.removeData(path: path)
            MediaPlayer.dataFromFile(file: self, updateDB: true) { [weak self] t, a, c, p in
                guard let self = self else { return }
                title = t
                artist = a ?? ""
                cover = c
                slowPeaks = p ?? []
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    static func == (lhs: FileData, rhs: FileData) -> Bool {
        lhs.id == rhs.id || lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
