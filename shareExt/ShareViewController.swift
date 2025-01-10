//
//  ShareViewController.swift
//  shareExt
//
//  Created by Max Sudovsky on 10.01.2025.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    var urls = [URL]()
    var playlists = [[String:Any]]()
    var images = [Int: Data?]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProviders = extensionItem.attachments else {
            close()
            return
        }
        
        playlists = getPlaylistInfo()
        for i in 0..<playlists.count {
            images[i] = (playlists[i]["cover"] as? Data)
        }

        let audioDataType = UTType.audio.identifier
        var index = 0
        
        for itemProvider in itemProviders {
            if itemProvider.hasItemConformingToTypeIdentifier(audioDataType) {
                
                // Load the item from itemProvider
                itemProvider.loadItem(forTypeIdentifier: audioDataType, options: nil, completionHandler: { url, error in
                    
                    if let url = url as? URL {
                        self.urls.append(url)
                    }
                    
                    index += 1
                    
                    if index == itemProviders.count {
                        if self.urls.count == 0 {
                            self.close()
                        }
                        
                        DispatchQueue.main.sync {
                            // host the SwiftU view
                            let contentView = UIHostingController(rootView: ShareView(urls: self.urls, images: self.images))
                            self.addChild(contentView)
                            self.view.addSubview(contentView.view)
                            
                            // set up constraints
                            contentView.view.translatesAutoresizingMaskIntoConstraints = false
                            contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                            contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
                            contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
                            contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
                        }
                    }
                })
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
        
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func getPlaylistInfo() -> [[String:Any]] {
        var result = [[String:Any]]()
        
        let fileManager = FileManager.default
        guard let commonurl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.cloudunion.music")?.appendingPathComponent("Playlists") else {
            return []
        }
        
        let url = commonurl.appendingPathComponent("Settings").appendingPathExtension("json")
        
        let pl = readJsn(file: url, as: [String:Any].self)
        let pList = pl?["sort"] as? [[String:Any]] ?? []
        
        for pl in pList {
            guard let name = pl["name"] as? String, let id = pl["id"] as? String else { continue }
            if let data = try? Data(contentsOf: commonurl.appendingPathComponent(name).appendingPathExtension("jpg")) {
                result.append(["id": id, "name": name, "cover": data])
            } else {
                result.append(["id": id, "name": name])
            }
            
        }
        
        return result
    }
    
    func readJsn<T>(file resource: URL, as asType: T.Type, fail: @escaping (String) -> Void = { _ in }) -> T? {
        
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
    
}
