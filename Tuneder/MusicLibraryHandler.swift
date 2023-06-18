//
//  MusicLibraryHandler.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import MediaPlayer

struct MusicLibraryHandler {
    var library: MPMediaLibrary
    
    init() {
        self.library = MPMediaLibrary.default()
    }
    
    func addSong(_ id: String) {
        library.addItem(withProductID: id)
    }
}
