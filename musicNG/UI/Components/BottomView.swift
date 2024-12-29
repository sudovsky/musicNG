//
//  BottomView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

struct BottomView: View {
    
    @Binding var page: Int
    
    var paction: () -> Void = { }
    var saction: () -> Void = { }
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                paction()
            } label: {
                Image(systemName: page == 1 ? "play.square.stack.fill" : "play.square.stack")
                    .imageScale(.large)
                    .foregroundColor(.main)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)

            Button {
                saction()
            } label: {
                Image(systemName: page == 1 ? "gearshape" : "gearshape.fill")
                    .imageScale(.large)
                    .foregroundColor(.main)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        }
    }
}

#Preview {
    BottomView(page: .constant(1))
}
