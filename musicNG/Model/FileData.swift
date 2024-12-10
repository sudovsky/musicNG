//
//  FileData.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import Foundation

class FileData: ObservableObject {
    
    @Published var name = ""
    var path = ""
    var size: Int64? = nil
    var createdDate: Date = Date()
    var modifiedDate: Date? = nil
    var isDirectory = false
    var isHidden = false
    @Published var title: String? = nil
    @Published var artist: String? = nil
    @Published var cover: Data? = nil
    var customSortKey = 0
    
    var peaks: [Float] { slowPeaks ?? fastPeaks }
    @Published var fastPeaks = [Float]()
    @Published var slowPeaks: [Float]? = nil
    
}
