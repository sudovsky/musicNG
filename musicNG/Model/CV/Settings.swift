//
//  Settings.swift
//  musicNG
//
//  Created by Max Sudovsky on 16.12.2024.
//

import Foundation
import SwiftUI

class Settings {
    
    static let shared = Settings()
    
    @AppStorage("username") var username = ""
    @AppStorage("password") var password = ""
    @AppStorage("address") var address = ""
    @AppStorage("shareName") var shareName = ""
    @AppStorage("lastPlaylistName") var lastPlaylistName: String?
    @AppStorage("lastSongName") var lastSongName: String?
    @AppStorage("lastSongPosition") var lastSongPosition: Double?

    @AppStorage("isAppInitiated") var isAppInitiated = false

    @AppStorage("repeatMode") var repeatMode: Int = 0 {
        didSet {
            PlaybackCoordinator.shared.repeatMode = repeatMode
        }
    }
    @AppStorage("shuffleMode") var shuffleMode: Int = 0 {
        didSet {
            PlaybackCoordinator.shared.shuffleMode = shuffleMode
        }
    }
    
    @AppStorage("sort") var sort: SortType = .userDefined
    
    private init() {}
    
}

func readJson<T>(file resource: URL, as asType: T.Type) throws -> T {
    
    let data = try Data(contentsOf: resource)
        
    if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .fragmentsAllowed]) as? T {
        return json
    } else {
        throw "Couldn't recognize JSON".error()
    }
    
}

var ios26: Bool {
    get {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }
}
