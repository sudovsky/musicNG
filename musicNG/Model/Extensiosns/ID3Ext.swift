//
//  ID3Ext.swift
//  musicNG
//
//  Created by Max Sudovsky on 22.12.2024.
//


import Foundation
import ID3TagEditor

//https://github.com/chicio/ID3TagEditor
extension FileData {
    
    func updateTextTags(title: String? = nil, artist: String? = nil, completion: @escaping (Data) -> Void = { _ in }) {
        getData { data in
            guard let data = data else { return }
            
            do {
                let id3TagEditor = ID3TagEditor()
                var id3Tag: ID3Tag
                
                if let oldId3Tag = try id3TagEditor.read(mp3: data) {
                    id3Tag = oldId3Tag
                } else {
                    if let title = title, let artist = artist {
                        id3Tag = ID32v3TagBuilder()
                            .title(frame: ID3FrameWithStringContent(content: title)).artist(frame: ID3FrameWithStringContent(content: artist)).build()
                        id3Tag.frames[.title] = ID3FrameWithStringContent(content: title)
                        id3Tag.frames[.artist] = ID3FrameWithStringContent(content: artist)
                    } else if let title = title {
                        id3Tag = ID32v3TagBuilder()
                            .title(frame: ID3FrameWithStringContent(content: title)).build()
                        id3Tag.frames[.title] = ID3FrameWithStringContent(content: title)
                    } else if let artist = artist {
                        id3Tag = ID32v3TagBuilder()
                            .artist(frame: ID3FrameWithStringContent(content: artist)).build()
                        id3Tag.frames[.artist] = ID3FrameWithStringContent(content: artist)
                    } else {
                        id3Tag = ID32v2TagBuilder().build()
                    }
                }
                
                if let title = title {
                    id3Tag.frames[.title] = ID3FrameWithStringContent(content: title)
                }
                if let artist = artist {
                    id3Tag.frames[.artist] = ID3FrameWithStringContent(content: artist)
                }
                let newData = try id3TagEditor.write(tag: id3Tag, mp3: data)
                
                completion(newData)
            } catch {
                print(error)
            }
        }
    }
    
    func getCurrentTag(_ frame: FrameName) -> String? {
        var currentValue: String? = nil
        
        let myGroup = DispatchGroup()

        myGroup.enter()

        getData { data in
            guard let data = data else { return }
            
            do {
                let id3TagEditor = ID3TagEditor()
                
                guard let oldId3Tag = try id3TagEditor.read(mp3: data) else {
                    currentValue = self.name
                    myGroup.leave()
                    return
                }
                
                currentValue = (oldId3Tag.frames[frame] as?  ID3FrameWithStringContent)?.content
                
                if currentValue?.trim().isEmpty ?? true {
                    currentValue = self.name
                }
                
                myGroup.leave()
            } catch {
                currentValue = self.name
                myGroup.leave()
                print(error)
            }
        }
        
        myGroup.wait()
        
        return currentValue
    }
    
    func updateCover(imageData: Data, completion: @escaping (Data) -> Void = { _ in }) {
        getData { data in
            guard let data = data else { return }
            
            do {
                let id3TagEditor = ID3TagEditor()
                var id3Tag: ID3Tag
                
                if let oldId3Tag = try id3TagEditor.read(mp3: data) {
                    id3Tag = oldId3Tag
                } else {
                    id3Tag = ID32v2TagBuilder().build()
                }
                
                id3Tag.frames[.attachedPicture(.frontCover)] = ID3FrameAttachedPicture(picture: imageData, type: .frontCover, format: .jpeg)

                let newData = try id3TagEditor.write(tag: id3Tag, mp3: data)
                
                completion(newData)
            } catch {
                print(error)
            }
        }
    }
}
