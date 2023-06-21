//
//  GenreSelection.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/20/23.
//

import Foundation
import MusicKit
import MusadoraKit

enum GenreSelection: CaseIterable, Identifiable, Equatable {
#warning("TODO: I'd like to have a lot more genres available for Tuneder. If there's a genre you'd like to see added, add it to this enum and add the MusicKit ID of the genre, along with a name, in ContentView.")
    case none
    case country
    case pop
    case rock
    case hiphop
    
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
        }
        
        return GenreData(name: name, id: id)
    }
}
