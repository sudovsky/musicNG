//
//  ContentView.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.10.2024.
//

import SwiftUI

struct AnimatedStarView: View {
    @State private var rotate = false
    @State private var scale: CGFloat = 0.5

    var body: some View {
        ZStack {
            StarShape()
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(.black)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(rotate ? 360 : 0))
//                .scaleEffect(scale)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: rotate)
//                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scale)
        }
        .onAppear {
            self.rotate.toggle()
//            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
//                self.scale = 1.0
//            }
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let starExtrusion: CGFloat = rect.width / 4
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let pointsOnStar = 5
        let angle = .pi / Double(pointsOnStar)

        var path = Path()

        for i in 0..<2*pointsOnStar {
            let extrude = CGFloat(i % 2 == 0 ? 1.0 : 0.5)
            let x = center.x + starExtrusion * extrude * CGFloat(cos(Double(i) * angle))
            let y = center.y + starExtrusion * extrude * CGFloat(sin(Double(i) * angle))
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        return path
    }
}

struct ContentView: View {
    var body: some View {
        AnimatedStarView()
    }
}

#Preview {
    ContentView()
}
