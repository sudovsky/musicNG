//
//  SMBClient.swift
//  musicNG
//
//  Created by Max Sudovsky on 29.12.2024.
//

import Foundation
import AMSMB2

class SMBClient {
    /// connect to: `smb://guest@XXX.XXX.XX.XX/share`
    
    var serverURL = URL(string: "smb://\(Settings.shared.address)")!
    var credential = URLCredential(user: Settings.shared.username, password: Settings.shared.password, persistence: URLCredential.Persistence.forSession)
    var share = Settings.shared.shareName
    
    lazy private var client = SMB2Manager(url: self.serverURL, credential: self.credential)
    
    func updateClient() {
        if let client = SMB2Manager(url: self.serverURL, credential: self.credential) {
            self.client = client
        }
    }
    
    private func connect() async throws -> SMB2Manager? {
        // AMSMB2 can handle queueing connection requests
        try await client?.connectShare(name: self.share)
        return self.client
    }
    
    
    private func disconnect() {
        // AMSMB2 can handle queueing connection requests
        client?.disconnectShare()
    }
    
    func getFileData(path: String, completion: @escaping (String?, Data?) -> Void = { _,_ in }) {
        client?.contents(atPath: path) { bytes, total in
            return true
        } completionHandler: { result in
            switch result {
            case .success(let files):
                let f = files
                print(f)
                completion(nil, f)
            case .failure(let error):
                //error.localizedDescription.showStandartOkMessage()
                completion(error.localizedDescription, nil)
            }
        }
        
    }
    
    func listDirectory(path: String, completion: @escaping (String?, [FileData]?) -> Void) {
        var findedFiles = [FileData]()

        Task {
            do {
                guard let client = try await connect() else { return }
                let files = try await client.contentsOfDirectory(atPath: path)
                for entry in files {
//                    print(
//                        "name:", entry[.nameKey] as! String,
//                        ", path:", entry[.pathKey] as! String,
//                        ", type:", entry[.fileResourceTypeKey] as! URLFileResourceType,
//                        ", size:", entry[.fileSizeKey] as! Int64,
//                        ", modified:", entry[.contentModificationDateKey] as! Date,
//                        ", created:", entry[.creationDateKey] as! Date)

                    if !(entry[.isDirectoryKey] as? Bool ?? false),  !FileData.isProper(filename: entry[.nameKey] as? String ?? "") {
                        continue
                    }
                    
                    let fileData = FileData(name: entry[.nameKey] as? String ?? "",
                                            path: (entry[.pathKey] as? String ?? "").trimmingCharacters(in: CharacterSet(charactersIn: "/")),
                                            createdDate: entry[.creationDateKey] as? Date,
                                            modifiedDate: entry[.contentModificationDateKey] as? Date,
                                            isDirectory: (entry[.fileResourceTypeKey] as? URLFileResourceType) == .directory,
                                            isHidden: entry[.isHiddenKey] as? Bool ?? false,
                                            size: entry[.fileSizeKey] as? Int64)
                    fileData.sourcePath = fileData.path
                    findedFiles.append(fileData)
                }
                DispatchQueue.main.async {
                    completion(nil, findedFiles)
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Get content error: \(error.localizedDescription)", nil)
                }
            }
        }
    }

    func listShare(completion: @escaping (String?, [String]?) -> Void = { _,_ in }) {
        client?.timeout = 5
        client?.listShares(completionHandler: { result in
            switch result {
            case .success(let client):
                var result = [String]()
                for file in client {
                    result.append(file.name)
                }
                DispatchQueue.main.async {
                    completion(nil, result)
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion("Share connect error: \(error.localizedDescription)", nil)
                }
            }
        })
    }

    func moveItem(path: String, to toPath: String) {
        Task {
            do {
                guard let client = try await connect() else { return }
                try await client.moveItem(atPath: path, toPath: toPath)
                print("\(path) moved successfully.")
                
                // Disconnecting is optional, it will be called eventually
                // when `AMSMB2` object is freed.
                // You may call it explicitly to detect errors.
                try await client.disconnectShare()
            } catch {
                print(error)
            }
        }
    }

}
