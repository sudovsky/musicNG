//
//  URLExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 19.12.2024.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }
}
