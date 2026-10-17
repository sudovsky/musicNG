//
//  HTag.swift
//  musicNG
//
//  Created by Max Sudovsky on 15.08.2026.
//

import Foundation

class HTag: Codable {
    
    var id = UUID().uuidString
    var name = ""
    var songs: [String] = []
    
}

class HTags: Codable {
    
    static var list = [HTag]()

    static func save() {
        try? list.save(FileManager.htags)
    }

    static func restore() {
        list = load(FileManager.htags) ?? []
    }
    
}
