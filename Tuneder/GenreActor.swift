//
//  GenreActor.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/21/23.
//

import Foundation
import MusicKit

/// Lets me pass genre data between concurrently and non-concurrently executing code.
actor GenreActor {
    var genre: Genre? = nil
    
    func set(_ newValue: Genre?) {
        genre = newValue
    }
}
