//
//  OKCancelMessage.swift
//  musicNG
//
//  Created by Max Sudovsky on 11.01.2025.
//

import SwiftUI

struct OKCancelMessage: ViewModifier {
    var showCancel: Bool
    @Binding var showingAlert: Bool
    
    @Binding var title: String
    @Binding var subtitle: String?
    
    var onOk: (() -> Void)? = nil

    func body(content: Content) -> some View {
        return AnyView(content
            .alert(title, isPresented: $showingAlert) {
                Button("OK", action: submit)
                if showCancel {
                    Button("Отмена", role: .cancel) { }
                }
            } message: { if subtitle == nil { EmptyView() } else { Text(subtitle ?? "") } }
            .alertButtonTint(color: .main)
        )
        
        func submit() {
            showingAlert = false
            DispatchQueue.global().async {
                onOk?()
            }
        }
    }
}

extension View {
    
    func okCancelMessage(showingAlert: Binding<Bool>, title: Binding<String> = .constant(""), subtitle: Binding<String?>? = nil, onOk: (() -> Void)? = nil) -> some View {
        modifier(OKCancelMessage(showCancel: true, showingAlert: showingAlert, title: title, subtitle: subtitle ?? .constant(nil), onOk: onOk))
    }
    
    func okMessage(showingAlert: Binding<Bool>, title: Binding<String> = .constant(""), subtitle: Binding<String?>? = nil, onOk: (() -> Void)? = nil) -> some View {
        modifier(OKCancelMessage(showCancel: false, showingAlert: showingAlert, title: title, subtitle: subtitle ?? .constant(nil), onOk: onOk))
    }
    
}
