//
//  ShareView.swift
//  musicNG
//
//  Created by Max Sudovsky on 10.01.2025.
//


import SwiftUI

struct ShareView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var urls: [URL]
    
    @State var playlists = [[String:Any]]()
    @State var images = [Int: Data?]()
    @State var listName: String? = nil

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Text("Выберите плейлист")
                    .font(.system(size: 21, weight: .light))
                    .padding()
                
                ScrollView {
//                    LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
//                        ForEach(playlists, id: \.self) { playlist in
//                            Button {
////                                onSelect(playlist, false)
////                                withAnimation {
////                                    use = false
////                                }
//                            } label: {
//                                Image(.no)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                            }
//                        }
//                        .id(UUID())
//                    }
//                    .padding([.horizontal, .bottom], 16)
                }
                .padding(.bottom, 16)
                
                Button {
                    saveFiles()
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
                .padding(16)
                .onAppear {
                }
            }
            .frame(maxHeight: 600)
            .background(Color.back)
            .cornerRadius(10)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding()
        }
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }

    private func saveFiles() {
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