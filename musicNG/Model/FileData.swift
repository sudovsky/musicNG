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
    
    init() { }
    
    init(name: String, path: String, customSortKey: Int) {
        self.name = name
        self.path = path
        self.customSortKey = customSortKey
    }
    
//    static private func readMetadata(for plist: [FileData], async: Bool = false, readedData: @escaping () -> Void = {}) {
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
//    }

}
