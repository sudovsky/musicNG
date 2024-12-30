//
//  RemoteViewDirectoryLine.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteViewDirectoryLine: View {
    
    @State var name: String = ""
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
            Text(name)
                .font(.system(size: 17))
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    RemoteViewDirectoryLine()
}
