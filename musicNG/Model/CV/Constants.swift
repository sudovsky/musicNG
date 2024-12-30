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

let titleFont: Font = .custom("avanti", size: 32) //.system(size: 19, weight: .regular)
let trackFont: Font = .custom("avanti", size: 19) //.system(size: 19, weight: .regular)
let artistFont: Font = .custom("Ampero-Regular", size: 18) //.system(size: 18, weight: .regular)
let mcTrackFont: Font = .custom("avanti", size: 28) //.system(size: 19, weight: .regular)
let mcArtistFont: Font = .custom("Ampero-Regular", size: 21) //.system(size: 18, weight: .regular)
let csTrackFont: Font = .custom("avanti", size: 19) //.system(size: 19, weight: .regular)
let csArtistFont: Font = .custom("Ampero-Regular", size: 18) //.system(size: 18, weight: .regular)

let remoteTrackFont: Font = .custom("avanti", size: 18) //.system(size: 19, weight: .regular)
let remoteArtistFont: Font = .custom("Ampero-Regular", size: 18) //.system(size: 18, weight: .regular)

let noImage = Image("NoImage")
    .resizable()

var standarts: [String] { ["MP3", "M4A"] }
