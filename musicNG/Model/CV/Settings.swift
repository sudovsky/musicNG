//
//  Settings.swift
//  musicNG
//
//  Created by Max Sudovsky on 16.12.2024.
//

import Foundation

class Settings: Codable {
    
    enum CodingKeys: CodingKey {
        case username
        case password
        case address
        case shareName
        case initiated
        case repeatMode
        case shuffleMode
        case sort
    }
    
    static let shared = Settings()
    
    var username = ""
    var password = ""
    var address = ""
    var shareName = ""
    
    var initiated = false

    var repeatMode: Int = 0 {
        didSet {
            PlaybackCoordinator.shared.repeatMode = repeatMode
            save()
        }
    }
    var shuffleMode: Int = 0 {
        didSet {
            PlaybackCoordinator.shared.shuffleMode = shuffleMode
            save()
        }
    }
    
    var sort: SortType = .userDefined
    
    private init() {
        load()
    }
    
    func save() {
        DispatchQueue.global().async {
            try? self.save(FileManager.appSettings)
        }
    }

    func load() {
        
        let pl = readJson(file: FileManager.appSettings, as: [String:Any].self)
        repeatMode = pl?["repeatMode"] as? Int ?? 2
        shuffleMode = pl?["shuffleMode"] as? Int ?? 0
        shareName = pl?["shareName"] as? String ?? ""
        username = pl?["username"] as? String ?? ""
        password = pl?["password"] as? String ?? ""
        address = pl?["address"] as? String ?? ""
        initiated = pl?["initiated"] as? Bool ?? false
        if let sortRaw = pl?["sort"] as? Int {
            sort = SortType(rawValue: sortRaw) ?? .userDefined
        }
    }
}

func readJson<T>(file resource: URL, as asType: T.Type, fail: @escaping (String) -> Void = { _ in }) -> T? {
    
    do {
        let data = try Data(contentsOf: resource)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .fragmentsAllowed]) as? T {
            return json
        } else {
            fail("Couldn't recognize JSON")
            return nil
        }
    } catch {
        print(error.localizedDescription)
        fail(error.localizedDescription)
        return nil
    }
    
}
