//
//  ShareView.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.01.2025.
//

import SwiftUI

struct SharePlaylist: Identifiable {
    var id: String
    var name: String
    var cover: UIImage?
}

struct ShareView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var urls: [URL]
    
    @State var playlists = [SharePlaylist]()

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Text("Select a playlist")
                    .font(.system(size: 21, weight: .light))
                    .padding([.vertical, .horizontal])
                
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                        ForEach(playlists) { playlist in
                            Button {
                                saveFiles(selectedList: playlist.name)
                            } label: {
                                ZStack {
                                    if let data = playlist.cover {
                                        Image(uiImage: data)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(10)
                                            .shadow(radius: 4)
                                    } else {
                                        Image(uiImage: UIImage(resource: .no))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(10)
                                            .shadow(radius: 4)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        Text(playlist.name)
                                            .frame(alignment: .bottom)
                                            .minimumScaleFactor(0.3)
                                            .font(.system(size: 18, weight: .medium))
                                            .shadow(color: .shadow, radius: 3, x: 0, y: 0)
                                            .foregroundStyle(.white)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(3)
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .id(UUID())
                    }
                    .padding([.horizontal], 16)
                    .padding(.vertical, 8)
                }
                .padding(.bottom, 16)
                
                Button {
                    saveFiles()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .frame(maxHeight: 52)
                            .foregroundStyle(Color.main)
                        Text("Create new")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.back)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
                Button {
                    close()
                } label: {
                    Text("Cancel")
                        .frame(height: 52)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.main)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }
            }
            .frame(maxHeight: 600)
            .background(Color.back)
            .cornerRadius(20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.horizontal, 8)
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }

    private func saveFiles(selectedList: String? = nil) {
        var listName = selectedList
        let commonurl = FileManager.globalDownloadsDir

        var settings = [String:[String]]()
        var currentList = [String]()
        
        let sett = load(FileManager.globalDownloadsSettingsFile) ?? [String:[String]]()
        if sett.count > 0 {
            settings = sett
            if let listName = listName {
                currentList = settings[listName] ?? []
            }
        }
        
        for url in urls {
            if url.startAccessingSecurityScopedResource() {
                let filePath = commonurl.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.copyItem(at: url, to: filePath)
                url.stopAccessingSecurityScopedResource()
            } else {
                let filePath = commonurl.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.copyItem(at: url, to: filePath)
            }
            
            if listName == nil { listName = url.deletingPathExtension().lastPathComponent }
            currentList.append(url.lastPathComponent)
        }
        
        settings[listName ?? ""] = currentList
        
        try? settings.save(FileManager.globalDownloadsSettingsFile)
        close()
        
    }
}

func readJson<T>(file resource: URL, as asType: T.Type, fail: @escaping (String) -> Void = { _ in }) -> T? {
    
    do {
        let data = try Data(contentsOf: resource)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .fragmentsAllowed]) as? T {
            return json
        } else {
            fail("Couldn't recognize JSON")
            return nil
        }
    } catch {
        print(error.localizedDescription)
        fail(error.localizedDescription)
        return nil
    }
    
}
