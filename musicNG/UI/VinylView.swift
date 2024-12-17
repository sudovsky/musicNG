//
//  VinylView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.11.2024.
//

import SwiftUI

struct VinylView: View {

    @ObservedObject var variables = Variables.shared

    @State private var rotate = false
    @State private var cover = noImage

    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.clear)
                .background(content: {
                    cover
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                })
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(rotate ? 360 : 0))

            Image(.vinyl)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blendMode(.screen)
            
            Circle()
                .stroke(.main.opacity(0.6), lineWidth: 4)
                .foregroundStyle(Color.clear)
        }
        .clipShape(Circle())
        .onAppear() {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotate.toggle()
            }
        }
        .onReceive(variables.$currentSong) { pub in
            withAnimation {
                cover = pub?.cover?.image() ?? noImage
            }
        }
    }
}

#Preview {
    VinylView()
}
