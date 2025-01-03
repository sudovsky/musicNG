//
//  RemoteViewFileLine.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteViewFileLine: View {

    @ObservedObject var pb = PlaybackCoordinator.shared

    @State var file: FileData
    @State var imageName: String = "play.circle.fill"

    var onPlay: ((FileData) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            (file.cover?.image() ?? Image(.no))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 48)
                .cornerRadius(10)
                .padding(.vertical, 8)

            VStack(spacing: 0) {
                Text(file.title ?? file.name)
                    .font(remoteTrackFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                if let artist = file.artist {
                    Text(artist)
                        .font(remoteArtistFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
            }
            
            Button {
                if Variables.shared.currentSong?.name == file.name {
                    if pb.isPlaying {
                        MediaPlayer.shared.pause()
                    } else {
                        MediaPlayer.shared.unpause()
                    }
                } else {
                    MediaPlayer.shared.pause()
                    onPlay?(file)
                }
            } label: {
                Image(systemName: imageName)
                    .font(.title)
            }
        }
        .padding(.horizontal, 16)
        .onReceive(pb.$isPlaying) { ip in
            if Variables.shared.currentSong?.name == file.name {
                imageName = ip ? "pause.circle.fill" : "play.circle.fill"
            } else {
                imageName = "play.circle.fill"
            }
        }
    }
}

#Preview {
    RemoteViewFileLine(file: FileData())
}
