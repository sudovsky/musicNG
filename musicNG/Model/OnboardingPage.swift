//
//  OnboardingPage.swift
//  musicNG
//
//  Created by Max Sudovsky on 23.02.2026.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    
    let id = UUID()
    var title: String
    var text: String
    var image: Image? = nil

    init(_ title: String, _ text: String, _ image: Image? = nil) {
        self.title = title
        self.text = text
        self.image = image
    }
    
}
