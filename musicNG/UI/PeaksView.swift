//
//  PeaksView.swift
//  musicNG
//
//  Created by Max Sudovsky on 15.12.2024.
//

import SwiftUI

struct PeaksView: View {
    var peaks: [Peak] = Peak.test
    var maxPeak: CGFloat = 1
    
    var onClick: ((CGPoint) -> Void)?

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(peaks) { peak in
                Color.main
                    .frame(width: 3, height: getSize(peak: peak).height)
                    .cornerRadius(3/2)
            }
        }
        .frame(height: 32, alignment: .bottom)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ val in
                    onClick?(val.location)
                })
        )
        
    }
    
    func getSize(peak: Peak) -> CGSize {
        let step: CGFloat = 3
        let height: CGFloat = 32
        var y = (height * peak.value) / CGFloat(maxPeak == 0 ? 1 : maxPeak)
        if y < step { y = step }
        
        return CGSize(width: step, height: y)
    }
    
}


#Preview {
    PeaksView()
}
