//
//  TagEditorLineView.swift
//  musicNG
//
//  Created by Max Sudovsky on 28.12.2024.
//

import SwiftUI

struct TagEditorLineView: View {
    
    @ObservedObject var file: TagLineData
    
    @State private var title: String = ""
    @State private var artist: String = ""

    var body: some View {
        HStack(spacing: 0) {
            Button {
                file.isChecked.toggle()
            } label: {
                Image(file.isChecked ? .checked : .unchecked)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28)
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(csTrackFont)
                Text(artist)
                    .font(csArtistFont)
            }
            .padding(.trailing, 16)
            
            Spacer()
        }
        .onReceive(file.$fileData) { fData in
            title = fData.title ?? fData.name
            artist = fData.artist ?? "Unknown"
        }
    }
}

#Preview {
    TagEditorLineView(file: TagLineData())
}
