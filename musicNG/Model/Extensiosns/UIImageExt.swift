//
//  UIImageExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.01.2025.
//

import UIKit

extension UIImage {
    
    func resizeImage(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

}
