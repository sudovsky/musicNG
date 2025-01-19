//
//  SongContext.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct SongContext: ViewModifier {
    var file: FileData
    var updateAction: (FileData) -> Void
    var action: (Int, FileData) -> Void = { _,_ in }
    
    func body(content: Content) -> some View {
        return AnyView(content
            .contextMenu {
                Section("Drag and drop of elements is only available when sorting by \"Custom\"") {
                    
                    if editableStandarts.contains(file.fileURL().pathExtension.uppercased()) {
                        Button {
                            file.updateTags {
                                updateAction(file)
                            }
                        } label: {
                            Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
                        }
                        Button {
                            action(1, file)
                        } label: {
                            Label("Change title", systemImage: "pencil")
                        }
                        Button {
                            action(2, file)
                        } label: {
                            Label("Change artist", systemImage: "pencil")
                        }
                        Button {
                            action(3, file)
                        } label: {
                            Label("Change cover", systemImage: "photo")
                        }
                    }
                    
                    Button {
                        action(4, file)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        action(5, file)
                    } label: {
                        Label("Move", systemImage: "play.square.stack.fill")
                    }
                }

                Button(role: .destructive) {
                    action(6, file)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        )

    }
}

extension View {
    func songContext(file: FileData, updateAction: @escaping (FileData) -> Void, action: @escaping (Int, FileData) -> Void = { _,_ in }) -> some View {
        modifier(SongContext(file: file, updateAction: updateAction, action: action))
    }
}
