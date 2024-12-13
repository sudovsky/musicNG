//
//  Constants.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

let commonCornerRadius: CGFloat = 11
let commonBorderWidth: CGFloat = 1
let commonBorderColor: Color = Color(.main.withAlphaComponent(0.2))
let commonShadowColor: Color = Color(.main.withAlphaComponent(0.25))
let comonTextColor: Color = .white
let commonGradientColor: Color = .black.opacity(0.2)

let artistFont: Font = .system(size: 18, weight: .regular)
let trackFont: Font = .system(size: 19, weight: .regular)

let noImage = Image("NoImage")
    .resizable()

var standarts: [String] { ["MP3", "M4A"] }
