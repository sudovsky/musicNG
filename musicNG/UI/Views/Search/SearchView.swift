//
//  SearchView.swift
//  musicNG
//
//  Created by Max Sudovsky on 24.01.2026.
//

import SwiftUI

struct SearchView: View {

    @ObservedObject var variables = Variables.shared

    @FocusState private var focusedField: Bool

    @State var loaded: Bool = false
    @State var text: String = ""
    @State var strings: [String] = []
    
    @State var allFiles = [FileData]()
    @State var found = [FileData]()
    
    var body: some View {
        ZStack {
            if loaded {
                ScrollView {
                    if found.count > 0 {
                        SearchResultsView(songs: $found)
                        Spacer()
                    } else if !text.isEmpty {
                        Text("Nothing found")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 89)
                        Spacer()
                    }
                }
                .contentMargin26(edges: .top, 66 + 54)
                .background(.back)
                
                VStack {
                    ZStack {
                        Color.clear
                            .frame(height: 44)

                        TextField("Title, artist, filename...", text: $text)
                            .focused($focusedField)
                            .padding(.horizontal, 16)
                    }
                    .glassed()

                    Spacer()
                }
                .padding(.top, 70)
                .padding(.horizontal, 8)

            } else {
                VStack {
                    Text("Loading...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 86)
                    Spacer()
                }
            }

        }
        .onChange(of: text) { newValue in
            found = filterFiles()
        }
        .onAppear {
            DispatchQueue.global().async {
                allFiles = getAllFiles()
                
                DispatchQueue.main.async {
                    withAnimation {
                        loaded = true
                    }
                }
            }
        }
    }
    
    func getAllFiles() -> [FileData] {

        let pl = Playlist.getAll(withCovers: false)
        var files = [FileData]()
        
        for plist in pl {
            files += plist.getDownloads(readMetadata: false)
            for file in files {
                file.readMetadata()
            }
        }
        
        return files
    }
    
    func filterFiles() -> [FileData] {
        if text.isEmpty {
            return []
        }
        
        var allFound = [FileData]()
        
        allFound += allFiles.filter { file in
            guard let title = file.title else { return false }
            
            return title.contains(text)
        }
        
        appendIfNeeded(source: &allFound, new: allFiles.filter { file in
            guard let artist = file.artist else { return false }
            
            return artist.contains(text)
        })
        
        appendIfNeeded(source: &allFound, new:
                        allFiles.filter { file in
            return file.name.contains(text)
        })
        
        return allFound
    }
    
    func appendIfNeeded(source: inout [FileData], new: [FileData]) {
        for newFile in new {
            if source.contains(where: { $0.id == newFile.id }) == false {
                source.append(newFile)
            }
        }
    }
}

#Preview {
    SearchView()
}
