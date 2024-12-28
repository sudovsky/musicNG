//
//  FileDataExt.swift
//  musicNG
//
//  Created by Max Sudovsky on 28.12.2024.
//

import SwiftUI

extension FileData {
    
    func updatePeaks(slowOnly: Bool = false) {
        MediaPlayer.shared.readBuffer(fileURL(), notify: false) { fast, data in
            if fast {
                if slowOnly { return }
                
                self.fastPeaks = data
                
                if Variables.shared.currentSong?.id == self.id {
                    withAnimation {
                        Variables.shared.currentSong = self
                    }
                }
            } else {
                self.slowPeaks = data

                if Variables.shared.currentSong?.id == self.id {
                    withAnimation {
                        Variables.shared.currentSong = self
                    }
                }

                if let dataLine = FilesMetaDB.data.first(where: {$0.path == self.path}) {
                    dataLine.peaks = data
                }
            }
        }
    }

}
