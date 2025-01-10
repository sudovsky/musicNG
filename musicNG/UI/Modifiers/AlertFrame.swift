//
//  AlertFrame.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//

import SwiftUI

struct AlertFrame: ViewModifier {
    @Binding var showingAlert: Bool
    @Binding var text: String
    
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var placeholder: String
    
    var onDone: ((String) -> Void)? = nil

    func body(content: Content) -> some View {
        return AnyView(content
            .alert(title, isPresented: $showingAlert) {
                TextField(placeholder, text: $text)
                Button("OK", action: submit)
                Button("Отмена", role: .cancel) { }
            } message: { if !subtitle.isEmpty { Text("Введите название песни") } }
            .alertButtonTint(color: .main)
        )
        
        func submit() { onDone?(text) }
    }
}

extension View {
    func alertFrame(showingAlert: Binding<Bool>, text: Binding<String>, title: Binding<String> = .constant(""), subtitle: Binding<String> = .constant(""), placeholder: Binding<String> = .constant(""), onDone: ((String) -> Void)? = nil) -> some View {
        modifier(AlertFrame(showingAlert: showingAlert, text: text, title: title, subtitle: subtitle, placeholder: placeholder, onDone: onDone))
    }
}
