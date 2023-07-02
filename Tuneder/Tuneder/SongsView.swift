//
//  SongView.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/23/23.
//

import SwiftUI
import MusadoraKit

/// This view renders the available elements in queue
struct SongsView: View {
    @Binding var queue: [Song]
    @Binding var showingErrorScreen: Bool
    @Binding var errorDescription: String
    
    var body: some View {
        ForEachWithIndex(data: self.queue.reversed()) { index, song in
            SongBackgroundView(song: song)
            SongPreviewView(queue: $queue, showingErrorScreen: $showingErrorScreen, errorDescription: $errorDescription, song: song)
                .padding()
                .frame(width: 380, height: 380)
                .animation(.spring(), value: UUID())
        }
    }
}

/// This view renders one element of queue at a time
struct SongView: View {
    @Binding var queue: [Song]
    @Binding var showingErrorScreen: Bool
    @Binding var errorDescription: String
    
    var song: Song {
        queue.first!
    }
    
    var body: some View {
        SongBackgroundView(song: song)
        SongPreviewView(queue: $queue, showingErrorScreen: $showingErrorScreen, errorDescription: $errorDescription, song: song)
            .padding()
            .frame(width: 380, height: 380)
            .animation(.spring(), value: UUID())
    }
}
