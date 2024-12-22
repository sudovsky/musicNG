//
//  UIApplicationExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//

import SwiftUI

extension UIApplication {
    static var window: UIWindow? {
        UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first { $0.isKeyWindow }
    }
}
