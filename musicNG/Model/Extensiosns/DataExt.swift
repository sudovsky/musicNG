//
//  DataExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.11.2024.
//

import SwiftUI

extension Data {
    public func image() -> Image? {
        if let uiimage = UIImage(data: self) {
            return Image(uiImage: uiimage)
        } else {
            return nil
        }
    }
}
