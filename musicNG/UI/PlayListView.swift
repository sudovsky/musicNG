//
//  PlayListView.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import SwiftUI

public struct PlayListView: View {

    @State private var showingDetail: Bool = false
    
    @State private var currentFrame: Int = 0

    var playlists: [Playlist] = [Playlist(), Playlist(), Playlist()]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public var body: some View {
        var currentPlaylist: Playlist?
        
        VStack(spacing: 0) {
            if currentFrame == 0 {
                Spacer()
                prepareData()
            } else if currentFrame == 1 {
                plView(action: { playlist in
                    currentPlaylist = playlist
                    showingDetail.toggle()
                })
                
                bottomView()
            } else if currentFrame == 2 {
                TitleView(backButtonVisible: false,
                          actionButtonVisible: false,
                          secondActionButton: false,
                          title: "Настройки")

                Spacer()
                
                bottomView()
            }
        }
        .background {
            Color.back
        }
        .fullScreenCover(isPresented: $showingDetail.animation(.interactiveSpring)) {
            SongTile(artist: currentPlaylist?.name ?? "")
        }

        
    }
    
    func prepareData() -> some View {
        Spacer()
            .onAppear {
                currentFrame = 1
            }
    }
    
    func bottomView() -> some View {
        BottomView {
            currentFrame = 1
        } saction: {
            currentFrame = 2
        }
    }
    
    func plView(action: @escaping (Playlist) -> Void) -> some View {
        return VStack(spacing: 0) {
            TitleView(backButtonVisible: false,
                      actionButtonVisible: true,
                      secondActionButton: true,
                      title: "Плейлисты") {
                print(1);
            } secondAction: {
                print(2)
            }

            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    ForEach(playlists) { playlist in
                        Button(action: {
                            action(playlist)
                        }, label: {
                            PlaylistTile(playlist: playlist)
                        })
                    }
                    Color(.white)
                }.padding(16)
            }

        }
    }
}

#Preview {
    PlayListView()
}

