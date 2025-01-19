//
//  Untitled.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import Foundation

enum SortType: Int, Codable {
    case userDefined = 0
    case name = 1
    case nameReverse = 2
    case date = 3
    case dateReverse = 4
    
    func caption() -> LocalizedStringResource {
        switch self {
        case .userDefined:
            "Custom"
        case .name:
            "A -> Z"
        case .nameReverse:
            "Z -> A"
        case .date:
            "Old -> New"
        case .dateReverse:
            "New -> Old"
        @unknown default:
            ""
        }
    }
}

