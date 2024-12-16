//
//  ScreenExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 16.12.2024.
//

import UIKit

extension UIScreen {
    
    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey:"_displayCornerRadius") as? CGFloat else {
            return 0
        }
        return cornerRadius
    }
    
    static func getSize() -> CGSize {
        
        if let windowSize = UIApplication.shared.connectedScenes
                        .compactMap({ scene -> UIWindow? in
                            (scene as? UIWindowScene)?.keyWindow
                        })
                        .first?
                        .frame
            .size {
            return windowSize
        } else {
            return UIScreen.main.bounds.size
        }

    }
}
