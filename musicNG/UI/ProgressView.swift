//
//  ProgressView.swift
//  musicNG
//
//  Created by Max Sudovsky on 13.12.2024.
//

import SwiftUI

struct ProgressView: View {
    
    var peaks: [Peak] = Peak.empty
    var maxPeak: CGFloat = 1

    @ObservedObject var pos = PositionCoordinator.shared

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                PeaksView(peaks: peaks, maxPeak: maxPeak)
                    .opacity(0.3)
                PeaksView(peaks: peaks, maxPeak: maxPeak) { point in
                    withAnimation {
                        if point.x >= CGFloat(peaks.count * 6 - 3) {
                            pos.position = CGFloat(peaks.count * 6 - 3)
                        } else {
                            pos.position = point.x < 0 ? 0 : point.x
                        }
                    }
                    
                    let xPos = point.x
                    let duration = MediaPlayer.shared.playerItem?.duration.seconds ?? 0
                    if duration.isNaN { return }
                    
                    let percentPos = xPos * 100 / UIScreen.waveWidth()
                    let songTime = duration / 100 * percentPos
                    MediaPlayer.shared.seek(positionTime: songTime)

                }
                .frame(width: pos.position, alignment: .leading)
                .clipped()
                
                Color.main
                    .frame(width: 1, height: 42)
                    .offset(x: pos.position)
                
            }
            .frame(height: 32)
            
            HStack {
                Text(pos.curTime)
                    .font(.system(size: 14, weight: .light))
                Spacer()
                Text(pos.endTime)
                    .font(.system(size: 14, weight: .light))
            }
            .padding(.horizontal, 32)
        }
    }
    
}

#Preview {
    ProgressView()
}
