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
                Section("Перетаскивание элементов доступно только при сортировке \"Пользовательская\"") {
                    
                    if file.fileURL().pathExtension.lowercased() == "mp3" {
                        Button {
                            file.updateTags {
                                updateAction(file)
                            }
                        } label: {
                            Label("Обновить", systemImage: "arrow.triangle.2.circlepath")
                        }
                        Button {
                            action(1, file)
                        } label: {
                            Label("Изменить название", systemImage: "pencil")
                        }
                        Button {
                            action(2, file)
                        } label: {
                            Label("Изменить исполнителя", systemImage: "pencil")
                        }
                        Button {
                            action(3, file)
                        } label: {
                            Label("Изменить обложку", systemImage: "photo")
                        }
                    }
                    
                    Button {
                        action(4, file)
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        action(5, file)
                    } label: {
                        Label("Переместить", systemImage: "play.square.stack.fill")
                    }
                }

                Button(role: .destructive) {
                    action(6, file)
                } label: {
                    Label("Удалить", systemImage: "trash")
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
