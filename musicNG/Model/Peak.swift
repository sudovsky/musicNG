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

extension Array where Element == Peak {
    
    var floatValues: [Float] {
        return self.map { Float($0.value) }
    }

    var maxPeak: CGFloat {
        
        let maxX = self.max { (firstElement, secondElement) -> Bool in
            return firstElement.value < secondElement.value
        }
        
        return CGFloat(maxX?.value ?? 1)
    }
    
}

extension Array where Element == Float {
    
    var peaks: [Peak] {
        var result = [Peak]()
        
        let count = self.count > PeaksView.peakCount() ? PeaksView.peakCount() : self.count
        
        for i in 0..<count {
            result.append(Peak(id: i, value: CGFloat(self[i] * self[i] * self[i])))
        }
        return result
    }
    
    var maxPeak: CGFloat {
        return peaks.maxPeak
    }
    
}
