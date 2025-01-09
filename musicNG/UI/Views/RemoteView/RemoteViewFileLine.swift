//
//  RemoteViewFileLine.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import SwiftUI

struct RemoteViewFileLine: View {

    @ObservedObject var pb = PlaybackCoordinator.shared
    @ObservedObject var variables = Variables.shared
    @ObservedObject var downloads = Downloads.shared

    @State var file: FileData
    @State var imageName: String = "play.circle.fill"
    @State var dimageName: String = "arrow.down.circle"

    @Binding var playlistSelection: Bool
    @Binding var filesToSave: [FileData]
    @Binding var readyToDownload: Bool

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
                if let _ = variables.currentPlaylist {
                    filesToSave = [file]
                    readyToDownload = true
                } else {
                    filesToSave = [file]
                    withAnimation {
                        playlistSelection.toggle()
                    }
                }
            } label: {
                Image(systemName: dimageName)
                    .font(.title)
            }
            
            Button {
                if variables.currentSong?.name == file.name {
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
            if variables.currentSong?.name == file.name {
                imageName = ip ? "pause.circle.fill" : "play.circle.fill"
            } else {
                imageName = "play.circle.fill"
            }
        }
        .onReceive(downloads.$downloads) { dl in
            guard let newFile = dl.first(where: { $0.file.path == file.path }) else { return }
            
            switch newFile.state {
            case .downloaded: dimageName = "checkmark.circle.fill"
            case .downloading: dimageName = "arrow.down.circle.fill"
            case .error: dimageName = "exclamationmark.circle.fill"
            default: break
            }
        }
    }
}

#Preview {
    RemoteViewFileLine(file: FileData(), playlistSelection: .constant(false), filesToSave: .constant([]), readyToDownload: .constant(false))
}
