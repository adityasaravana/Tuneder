//
//  MusicItemCollection.mapToSongArray.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/20/23.
//

import Foundation
import MusicKit

extension MusicItemCollection<Song> {
    func mapToSongArray() -> [Song] {
        var array: [Song] = []
        for song in self {
            array.append(song)
        }
        return array
    }
}
