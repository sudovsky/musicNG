//
//  OutlinedText.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.10.2026.
//

import SwiftUI

struct OutlinedText: View {
    var text: String
    var width: CGFloat
    var color: Color
    
    var body: some View {
        let diagonal: CGFloat = 1/sqrt(2) * width
        ZStack{
            ZStack{
                // bottom right
                Text(text).offset(x:  diagonal, y:  diagonal)
                // top left
                Text(text).offset(x: -diagonal, y: -diagonal)
                // bottom left
                Text(text).offset(x: -diagonal, y:  diagonal)
                // top right
                Text(text).offset(x:  diagonal, y: -diagonal)
                // left
                Text(text).offset(x:  -width, y: 0)
                // right
                Text(text).offset(x:  width, y: 0)
                // top
                Text(text).offset(x:  0, y: -width)
                // bottom
                Text(text).offset(x:  0, y: width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}
