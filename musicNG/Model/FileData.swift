//
//  FileData.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import Foundation

class FileData: Codable, Identifiable {
    
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
            cover = fdbl.cover?.jpg
            if let p = fdbl.peaks {
                slowPeaks = p
            }
            return
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
    

}
