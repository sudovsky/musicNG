//
//  PlayControlButton.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.12.2024.
//

import SwiftUI

struct PlayControlButton: View {
    var imageName: String = "play.fill"
    var isBig: Bool = false
    var action: () -> Void = { }

    @ObservedObject var pos = PositionCoordinator.shared

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.main)
                Image(systemName: !isBig ? imageName : (pos.isPlaying ? "pause.fill" : "play.fill"))
                    .foregroundStyle(.back)
                    .font(isBig ? .system(size: 33) : .system(size: 17, weight: .ultraLight))
            }
        }
        .buttonStyle(GrowingButton())
        .shadowed()
    }
}

#Preview {
    PlayControlButton()
}
