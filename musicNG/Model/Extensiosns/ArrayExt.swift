//
//  ArrayExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 19.12.2024.
//

import Foundation

extension Array {
    
    func getTwoArrays() -> ([Element], [Element]) {
        guard !isEmpty else { return ([], []) }
        
        var ar1: [Element] = []
        var ar2: [Element] = []
        
        for i in 0..<self.count {
            if i % 2 == 0 {
                ar1.append(self[i])
            } else {
                ar2.append(self[i])
            }
        }
        return (ar1, ar2)
    }
    
    
    func getManyArrays() -> [[Element]] {
        guard !isEmpty else { return [[Element]]() }
        
        var result = [[Element]]()
        
        var ar1: Element? = nil
        var ar2: Element? = nil
        
        for i in 0..<self.count {
            if i % 2 == 0 {
                ar1 = self[i]
            } else {
                ar2 = self[i]
                
                result.append([ar1!, ar2!])
                ar1 = nil
                ar2 = nil
            }
        }
        
        if let ar1 {
            result.append([ar1])
        }
        
        return result
    }
    
}
