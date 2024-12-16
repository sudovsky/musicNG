//
//  Settings.swift
//  musicNG
//
//  Created by Max Sudovsky on 16.12.2024.
//

import Foundation

class Settings {
    
    static let shared = Settings()
    
    var username = ""
    var password = ""
    var address = ""
    var shareName = ""
    
    var repeatMode: Int = 0
    var shuffleMode: Int = 0
    
    var sort: SortType = .userDefined
    
    private init() {
        //load()
    }
    
}
