//
//  TitleView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct TitleView: View {

    @Environment(\.dismiss) var dismiss

    @State var backButtonVisible = false
    @State var actionImage: Image? = nil
    @State var secondActionImage: Image? = nil
    
    var title = "Плейлисты"

    var action = {}
    var secondAction = {}

    public var body: some View {
        HStack(spacing: 0) {
            if backButtonVisible {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .titleButtonImage(.leading)
                }
                .frame(width: 44, alignment: .center)
            }
            
            Text(title)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, backButtonVisible ? 0 : 16)
            
            if let actionImage = actionImage {
                Button {
                    action()
                } label: {
                    actionImage
                        .titleButtonImage(.trailing)
                }
                .frame(width: 44, alignment: .center)
            }
            
            if let secondActionImage = secondActionImage {
                Button {
                    secondAction()
                } label: {
                    secondActionImage
                        .titleButtonImage(.trailing)
                }
                .frame(width: 44, alignment: .center)
            }
                
        }
        .frame(maxWidth: .infinity, minHeight: 44)

    }
}

#Preview {
    TitleView()
}
