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
    
    func caption() -> String {
        switch self {
        case .userDefined:
            "Пользовательская"
        case .name:
            "От А до Я"
        case .nameReverse:
            "От Я до А"
        case .date:
            "Сначала старые"
        case .dateReverse:
            "Сначала новые"
        @unknown default:
            ""
        }
    }
}

