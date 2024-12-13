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
    
    var body: some View {
        ZStack {
            Circle()
                .overlay {
                    (Variables.shared.currentSong?.cover?.image() ?? noImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: rotate)

            Image(.vinyl)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .blendMode(.screen)
            
            Circle()
                .stroke(.main.opacity(0.6), lineWidth: 4)
                .foregroundStyle(Color.clear)
        }
        .clipShape(Circle())
        //.border(Circle(), width: 2)
        .onAppear() {
            rotate.toggle()
        }
    }
}

#Preview {
    VinylView()
}
