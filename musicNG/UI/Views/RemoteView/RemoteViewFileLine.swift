//
//  RemoteViewFileLine.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteViewFileLine: View {
    
    @State var title: String = ""
    @State var artist: String? = nil
    @State var image: Data? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 0) {
                Text(title)
                    .font(remoteTrackFont)
                if let artist = artist {
                    Text(artist)
                        .font(remoteArtistFont)
                }
            }
            
            Spacer()
            
            (image?.image() ?? Image(.no))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 64)
                .cornerRadius(10)
                .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    RemoteViewFileLine()
}
