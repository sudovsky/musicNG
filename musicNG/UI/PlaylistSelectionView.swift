//
//  PlaylistSelectionView.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//

import SwiftUI

struct PlaylistSelectionView: View {

    @Binding var use: Bool

    var canCreate = true

    var playlists: [Playlist] = Playlist.getAll(withCovers: true)

    var onSelect: (Playlist?, Bool) -> Void = { _,_ in }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Button {
                withAnimation {
                    use = false
                }
            } label: {
                Color.main
                    .opacity(0.01)
            }

            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Text("Выберите плейлист")
                        .font(.system(size: 21, weight: .light))
                        .padding()
                    
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                            ForEach(playlists, id: \.self) { playlist in
                                Button {
                                    onSelect(playlist, false)
                                    withAnimation {
                                        use = false
                                    }
                                } label: {
                                    SongTile(image: playlist.cover?.image() ?? noImage, artistVisible: false, track: playlist.name, shadow: true, gradient: true, destination: .plSelection)
                                }
                                .buttonStyle(GrowingButton())
                            }
                            .id(UUID())
                        }
                    }
                    .padding([.horizontal, .bottom], 16)

                    if canCreate {
                        Button {
                            onSelect(nil, true)
                            withAnimation {
                                use = false
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                    .frame(maxHeight: 52)
                                    .foregroundStyle(Color.main)
                                Text("Создать новый")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(.back)
                            }
                            .padding([.horizontal, .bottom], 16)
                        }
                        .buttonStyle(GrowingButton())
                    }
                    
                }
                .frame(maxHeight: 600)
                .background(Color.back)
                .cornerRadius(10)
                .padding()
                .shadowed()
            }
        }
    }
}

#Preview {
    PlaylistSelectionView(use: .constant(true))
}
