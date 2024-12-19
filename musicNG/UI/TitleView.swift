//
//  TitleView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct TitleView: View {

    @Environment(\.dismiss) var dismiss

    @ObservedObject var playlist = PlaylistCoordinator.shared

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
                    playlist.currentPlaylist = nil
                } label: {
                    Image(systemName: "chevron.left")
                        .titleButtonImage(.leading)
                }
                .frame(width: 44, alignment: .center)
            }
            
            Text(playlist.currentPlaylist?.name ?? title)
                .font(titleFont)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, backButtonVisible ? 0 : 16)
                .padding(.trailing, 16)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            
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
        .onReceive(playlist.$currentPlaylist) { plist in
            withAnimation {
                backButtonVisible = plist?.id != nil
            }
        }

    }
}

#Preview {
    TitleView()
}
