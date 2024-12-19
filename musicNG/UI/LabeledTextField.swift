//
//  LabeledTextField.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct LabeledTextField: View {
    
    var title: String = ""
    var onChange: ((String) -> Void)?
    
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(.main.opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: 42)
            TextField(title, text: $text)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .onChange(of: text) { newValue in
                    onChange?(newValue)
                }
        }
    }
}

#Preview {
    LabeledTextField()
}
