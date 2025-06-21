//
//  StringExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 13.12.2024.
//

import Foundation

extension String {
    
    func nameWithoutDot() -> String {
        let components = self.components(separatedBy: ".")
        var fileName = ""
        for i in 0..<components.count-1 {
            fileName += components[i]
        }
        return fileName.replacingOccurrences(of: ".", with: "") + "." + (components.last ?? "")
    }

    func error(code: Int = 1) -> NSError {
        NSError(domain: NSOSStatusErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: self])
    }
}
