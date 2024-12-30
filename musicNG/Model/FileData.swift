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
    
    init(name: String, path: String, createdDate: Date? = nil, modifiedDate: Date? = nil, isDirectory: Bool = false, isHidden: Bool = false, size: Int64? = nil, customSortKey: Int? = nil) {
        self.name = name
        self.path = path
        self.createdDate = createdDate ?? Date()
        self.modifiedDate = modifiedDate
        self.isDirectory = isDirectory
        self.isHidden = isHidden
        self.size = size
        self.customSortKey = customSortKey ?? 0
    }
    
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
        var result = name.lowercased()

        var maskParts = getArrayOfTags(from: sourceTemplate.lowercased())
        
        if let firstPart = maskParts.first, !firstPart.hasPrefix("%") {
            if result.hasPrefix(firstPart) {
                result = result.stringByReplacingFirstOccurrenceOfString(target: firstPart, withString: "")
            }
            maskParts.removeFirst()
        }
        
        if let lastPart = maskParts.last, !lastPart.hasPrefix("%") {
            if result.hasSuffix(lastPart) {
                result.removeLast(lastPart.count)
            }
            maskParts.removeLast()
        }
        
        var preRes = [String:String]()
        
        //здесь по идее первый всегда тэг
        while let firstPart = maskParts.first {
            maskParts.removeFirst()

            if maskParts.isEmpty {
                if !result.isEmpty {
                    preRes[firstPart] = result
                }
                break
            }
            
            var tempStr = ""
            let secondPart = maskParts.first!
            maskParts.removeFirst()
            while result.count > 0, !result.hasPrefix(secondPart) {
                tempStr += String(result.removeFirst())
            }
            
            if result.hasPrefix(secondPart) {
                result.removeFirst(secondPart.count)
            }
            
            if !tempStr.isEmpty {
                preRes[firstPart] = tempStr
            }
        }

        return preRes[tagName]
    }

    func getArrayOfTags(from string: String) -> [String] {
        let percentCount = string.count(where: { $0 == "%"})
        if  percentCount == 0 || percentCount % 2 != 0 {
            return []
        }
        
        var result = [String]()
        var currentStr = ""
        var insideTag = false

        for char in string {
            if char == "%" {
                if insideTag {
                    result.append("%" + currentStr + "%")
                } else {
                    result.append(currentStr)
                }
                currentStr = ""
                insideTag.toggle()
            } else {
                currentStr.append(char)
            }
        }
        
        if !currentStr.isEmpty {
            result.append(currentStr)
        }
        
        return result
    }
    
    static func isProper(filename: String) -> Bool {
        let components = filename.components(separatedBy: ".")
        return standarts.contains(components.last?.uppercased() ?? "")
    }
    
    static func == (lhs: FileData, rhs: FileData) -> Bool {
        lhs.id == rhs.id || lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
