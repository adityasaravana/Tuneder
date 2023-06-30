//
//  MusicManager.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/28/23.
//

import MusadoraKit
import Defaults

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
            var request = await MusicCatalogChartsRequest(genre: genre.genreData.catalogData(), types: [Song.self])
            request.offset = 5000
            
            let response = try await request.response()
            print("ExplicitContentAllowed: \(Defaults[.explicitContentAllowed])")
            if Defaults[.explicitContentAllowed] {
                reserve = response.songCharts.first?.items.reversed().reversed() ?? []
            } else {
                if let cleanedResponse = try await response.songCharts.first?.items.clean {
                    for song in cleanedResponse {
                        if song.contentRating != .explicit {
                            print("\(song.title) is \(String(describing: song.contentRating))")
                            reserve.append(song)
                        }
                    }
                }
            }
            
        } catch {
            
        }
    }
    
    
    func addRelatedSongs(from song: Song) async {
        do {
            if reserve.count >= 10 {
                reserve = reserve.dropLast(reserve.count - 10)
            }
            
            let id = song.id
            
            let songData = try await MCatalog.song(id: id, fetch: [.artists])
            let songArtistID = songData.artists!.first!.id
            let songArtist = try await MCatalog.artist(id: songArtistID, fetch: [.similarArtists, .topSongs])
            
            if let songArtistTopSong = songArtist.topSongs?.first! {
                if songArtistTopSong.contentRating == .explicit {
                    if Defaults[.explicitContentAllowed] {
                        reserve.append(songArtistTopSong)
                    }
                } else {
                    reserve.append(songArtistTopSong)
                }
            }
            
            for relatedArtist in songArtist.similarArtists! {
                print("Recommending Top Song From Artist: \(relatedArtist.name)")
                let relatedArtistID = relatedArtist.id
                let relatedArtistData = try await MCatalog.artist(id: relatedArtistID, fetch: [.topSongs])
                if let relatedArtistTopSong = relatedArtistData.topSongs!.first {
                    if relatedArtistTopSong.contentRating == .explicit {
                        if Defaults[.explicitContentAllowed] {
                            reserve.append(relatedArtistTopSong)
                        }
                    } else {
                        reserve.append(relatedArtistTopSong)
                    }
                }
            }
        } catch {
            print("MusicManager.addRelatedSongs caught...")
        }
    }
    
    func search(_ query: String) async {
        /// This code fetches the genres and ids of songs that that you enter in searchTerm, useful for adding more genres (See GenreSelection)
        do {
            let songSearch = try await MCatalog.search(for: query, types: [.songs], limit: 3)
            for song in songSearch.songs {
                let songDetailed = try await MCatalog.song(id: song.id, fetch: [.genres])
                
                for genre in songDetailed.genres! {
                    print("⚠️⚠️⚠️⚠️⚠️⚠️ GENRE NAME: \(genre.name), ID: \(genre.id) ⚠️⚠️⚠️⚠️⚠️⚠️")
                }
            }
        } catch {
            print("caught at MusicManager.searchQuery")
        }
    }
}
