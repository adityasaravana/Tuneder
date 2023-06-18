//
//  Song.relatedSongs.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import Foundation
import MusicKit

//extension Song {
//    func relatedSongs() async -> MusicItemCollection<Song> {
//        
//        do {
//            let album = self.albums?.first
//            let detailedAlbum = try await album?.with([.relatedAlbums])
//            if let relatedAlbums = detailedAlbum?.relatedAlbums, !relatedAlbums.isEmpty {
//                print("Related albums for \(album): \(relatedAlbums)")
//                return relatedAlbums.first?.tracks
//            } else {
//                print("No related albums could be found for \(album).")
//                return []
//            }
//        } catch {
//            print("Caught at Song.relatedSongs.swift: Song.relatedSongs")
//            return []
//        }
//        
//    }
//}
