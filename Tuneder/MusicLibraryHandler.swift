//
//  MusicLibraryHandler.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import MediaPlayer

/// This just makes it nicer to add songs to the user's library when they swipe right
struct MusicLibraryHandler {
    static let tunederPlaylistID = UUID()
    var library: MPMediaLibrary
    
    init() {
        self.library = MPMediaLibrary.default()
    }
    
    func addSong(_ id: String) {
//        library.addItem(withProductID: id)
        library.getPlaylist(with: MusicLibraryHandler.tunederPlaylistID, creationMetadata: MPMediaPlaylistCreationMetadata(name: "Liked Songs"), completionHandler: { playlist, error in
            playlist?.addItem(withProductID: id)
        })
    }
}
