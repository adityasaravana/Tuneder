//
//  MusicManager.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/28/23.
//

import MusadoraKit

class MusicManager {
    init() {
        
    }
    
    static let shared: MusicManager = {
        let instance = MusicManager()
        // setup code
        return instance
    }()
    
    var reserve: [Song] = []
//    {
//        didSet {
//            removeDuplicates()
//        }
//    }
    
    func fetch() -> [Song] {
        let fetchedSongs = Array(reserve.prefix(5))
        reserve = Array(reserve.dropFirst(5))
        return fetchedSongs
    }
    
    func removeDuplicates() {
        let cleaned = Set(reserve)
        reserve = Array(cleaned)
    }
    
    func addChartSongs(genre: GenreSelection) async {
        do {
            let request = await MusicCatalogChartsRequest(genre: genre.genreData.catalogData(), types: [Song.self])
            
            let response = try await request.response()
            
            reserve = response.songCharts.first?.items.reversed().reversed() ?? []
        } catch {
            
        }
    }
    
    
    func addRelatedSongs(from song: Song) async {
        do {
            let id = song.id
            
            let songData = try await MCatalog.song(id: id, fetch: [.artists])
            let songArtistID = songData.artists!.first!.id
            let songArtist = try await MCatalog.artist(id: songArtistID, fetch: [.similarArtists, .topSongs])
            
            if let songArtistTopSong = songArtist.topSongs?.first! {
                reserve.append(songArtistTopSong)
            }
            
            for relatedArtist in songArtist.similarArtists! {
                print("Recommending Top Song From Artist: \(relatedArtist.name)")
                let relatedArtistID = relatedArtist.id
                let relatedArtistData = try await MCatalog.artist(id: relatedArtistID, fetch: [.topSongs])
                if let relatedArtistTopSong = relatedArtistData.topSongs!.first {
                    reserve.append(relatedArtistTopSong)
                }
            }
        } catch {
            print("MusicManager.addRelatedSongs caught...")
        }
    }
    
    func search(query: String) {
        
    }
    
    
}
