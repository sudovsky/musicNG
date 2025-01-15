//
//  TitleView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct TitleView: View {

    @Environment(\.dismiss) var dismiss

    @Binding var backButtonVisible: Bool
    @Binding var title: String
    @Binding var actionsVisible: Bool

    @State var backButtonImage: Image? = nil
    @State var actionImage: Image? = nil
    @State var secondActionImage: Image? = nil

    var action = {}
    var secondAction = {}
    var backAction = {}

    public var body: some View {
        HStack(spacing: 0) {
            if backButtonVisible {
                Button {
                    backAction()
                } label: {
                    (backButtonImage ?? Image(systemName: "chevron.left"))
                        .titleButtonImage(.leading)
                }
                .frame(width: 44, alignment: .center)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            
            Text(title)
                .font(titleFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, backButtonVisible ? 0 : 16)
                .padding(.trailing, 16)
                .lineLimit(2)
                .minimumScaleFactor(0.3)
            
            if let actionImage = actionImage {
                Button {
                    action()
                } label: {
                    actionImage
                        .titleButtonImage(.trailing)
                }
                .frame(width: 44, alignment: .center)
                .opacity(actionsVisible ? 1 : 0)
            }
            
            if let secondActionImage = secondActionImage {
                Button {
                    secondAction()
                } label: {
                    secondActionImage
                        .titleButtonImage(.trailing)
                }
                .frame(width: 44, alignment: .center)
                .opacity(actionsVisible ? 1 : 0)
            }
                
        }
        .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)

    }
}

#Preview {
    TitleView(backButtonVisible: .constant(false), title: .constant("Preview"), actionsVisible: .constant(true))
}
