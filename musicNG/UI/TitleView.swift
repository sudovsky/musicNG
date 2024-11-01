//
//  TitleView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct TitleView: View {
    
    @State var backButtonVisible = false
    @State var actionButtonVisible = true
    @State var secondActionButton = true
    
    var title = "Плейлисты"

    var action = {}
    var secondAction = {}

    public var body: some View {
        HStack(spacing: 0) {
            if backButtonVisible {
                Button {
                    print("back")
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .foregroundColor(.main)
                        .padding(.leading, 8)
                        .padding(.bottom, 4)
                }
                .frame(width: 44, alignment: .center)
            }
            
            Text(title)
                .font(.system(size: 25, weight: .light))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, backButtonVisible ? 0 : 16)
            
            if actionButtonVisible {
                Button {
                    action()
                } label: {
                    Image(systemName: "network")
                        .font(.system(size: 25))
                        .foregroundColor(.main)
                        .padding(.trailing, 8)
                        .padding(.bottom, 4)
                }
                .frame(width: 44, alignment: .center)
            }
            
            if secondActionButton {
                Button {
                    secondAction()
                } label: {
                    Image(.plus)
                        .font(.system(size: 25))
                        .foregroundColor(.main)
                        .padding(.trailing, 8)
                        .padding(.bottom, 4)
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
