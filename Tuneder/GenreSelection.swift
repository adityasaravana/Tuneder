//
//  GenreSelection.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/20/23.
//

import Foundation
import MusadoraKit

enum GenreSelection: CaseIterable, Identifiable, Equatable {
    // TODO: I'd like to have a lot more genres available for Tuneder. If there's a genre you'd like to see added, add it to this enum. You'll need the MusicKit ID & name of the genre (see MusicManager.search)."
    case none
    case country
    case pop
    case rock
    case hiphop
    case rnbsoul
    case metal
    case blues
    case jazz
    case electronic
    case alternative
    
    var id: Self { self }
    
    var genreData: GenreData {
        var name = ""
        var id: MusicItemID? = nil
        
        switch self {
        case .none:
            name = "None"
        case .country:
            name = "Country"
            id = "6"
        case .pop:
            name = "Pop"
            id = "14"
        case .rock:
            name = "Rock"
            id = "21"
        case .hiphop:
            name = "Hip-Hop/Rap"
            id = "18"
        case .rnbsoul:
            name = "R&B/Soul"
            id = "15"
        case .metal:
            name = "Metal"
            id = "1153"
        case .blues:
            name = "Blues"
            id = "2"
        case .jazz:
            name = "Jazz"
            id = "11"
        case .electronic:
            name = "Electronic"
            id = "7"
        case .alternative:
            name = "Alternative"
            id = "20"
            
        }
        
        return GenreData(name: name, id: id)
    }
}
