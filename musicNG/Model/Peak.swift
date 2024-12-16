//
//  Peak.swift
//  musicNG
//
//  Created by Max Sudovsky on 15.12.2024.
//

import Foundation

struct Peak: Identifiable {
    let id: Int
    var value: CGFloat
    
    static var empty: [Peak] {
        
        var result = [Peak]()
        
        for i in 0..<PeaksView.peakCount() {
            result.append(Peak(id: i, value: 0))
        }
        
        return result
    }
}


