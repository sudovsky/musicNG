//
//  Localization.swift
//  musicNG
//
//  Created by Max Sudovsky on 19.01.2025.
//

//https://stackoverflow.com/questions/25081757/whats-nslocalizedstring-equivalent-in-swift

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
