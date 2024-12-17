//
//  Sequence.swift
//  musicNG
//
//  Created by Max Sudovsky on 17.12.2024.
//

import Foundation

extension Sequence {
    func max<T: Comparable>(_ predicate: (Element) -> T)  -> Element? {
        self.max(by: { predicate($0) < predicate($1) })
    }
    func min<T: Comparable>(_ predicate: (Element) -> T)  -> Element? {
        self.min(by: { predicate($0) < predicate($1) })
    }
}
