//
//  FileData.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import Foundation

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
            } else {
                updatePeaks(slowOnly: true)
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
        
        if peaks.isEmpty { updatePeaks() }
        
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
    
    func saveData(data: Data) {
        // TODO: - проверить нужно ли писать в фоне
        //DispatchQueue.global().async {
            do {
                let url = fileURL(needCreate: true)
                try data.write(to: url, options: .atomic)
            } catch {
        //        DispatchQueue.main.async {
                    print(error.localizedDescription, "Can'not save local db")
        //        }
            }
        //}
    }

    func deleteData() {
        do {
            if fileDownloaded {
                try FileManager.default.removeItem(at: fileURL())
            }
        } catch {
            print(error.localizedDescription, "Can'not load local db")
        }
    }
    
    func removeDownload() {
        do {
            try FileManager.default.removeItem(at: fileURL())
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getTagFromName(sourceTemplate: String, tagName: String) -> String? {
        guard let url = URL(string: name.trim().lowercased()), url.pathExtension == "mp3" else { return nil }
        
        var template = sourceTemplate
        guard var tagRange = template.range(of: tagName) else { return nil }
        var firstPart = String(template[..<tagRange.lowerBound])
        
        while let fp = firstTagFromString(source: firstPart) {
            let newFp = getTagFromName(sourceTemplate: template, tagName: fp) ?? ""
            template = template.replacingOccurrences(of: fp, with: newFp)
            tagRange = template.range(of: tagName, options: .widthInsensitive) ?? tagRange
            firstPart = String(template[..<tagRange.lowerBound])
        }
        
        var stringBeforeNext = ""
        for i in template[tagRange.upperBound...] {
            if i == "%" { break }
            stringBeforeNext += String(i)
        }

        var cname = name
        let crange = cname.range(of: cname)!
        if crange.upperBound < tagRange.lowerBound {
            return nil
        }

        if String(cname[..<tagRange.lowerBound]) == firstPart {
            cname = String(cname[tagRange.lowerBound...])
        } else {
            return nil
        }
        
        guard let nextStringRange = cname.range(of: stringBeforeNext) else { return cname }

        let finalString = String(cname[..<nextStringRange.lowerBound])
        
        return finalString
    }

    func firstTagFromString(source: String) -> String? {
        if !source.contains(where: {$0 == "%"}) {
            return nil
        }
        
        var result = ""
        var needUpdate = false
        for i in source {
            if needUpdate { result += String(i) }
            
            if i == "%" {
                if needUpdate {
                    break
                } else {
                    result += String(i)
                    needUpdate = true
                }
            }
        }
        
        return result.count > 2 ? result : nil
    }

    static func == (lhs: FileData, rhs: FileData) -> Bool {
        lhs.id == rhs.id || lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
