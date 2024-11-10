//
//  JSONExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 31.10.2024.
//

import Foundation

func load<T: Decodable>(_ file: URL) -> T? {
    let data: Data

    do {
        data = try Data(contentsOf: file)
    } catch {
        print("Couldn't load \(file.absoluteString) from main bundle:\n\(error)")
        return nil
    }

    do {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode(T.self, from: data)
    } catch {
        print("Couldn't parse \(file.absoluteString) as \(T.self):\n\(error)")
        return nil
    }
}

extension Encodable {
    func toJSON() throws -> String? {
        let encoder = JSONEncoder()
        return try String(data: encoder.encode(self), encoding: .utf8)
    }
    
    func save(_ file: URL) throws {
        if let text = try toJSON() {
            if FileManager.default.fileExists(atPath: file.path) {
                try FileManager.default.removeItem(at: file)
            }
            
            FileManager.default.createFile(atPath: file.path, contents: text.data(using: .utf8))
        }
    }
}
