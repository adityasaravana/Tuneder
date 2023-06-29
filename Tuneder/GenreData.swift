//
//  GenreData.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/20/23.
//

import Foundation
import MusadoraKit

struct GenreData: Codable {
    var name: String
    var id: MusicItemID?
    
    func catalogData() async -> Genre? {
        let staticid = id
        
        let genreActor: GenreActor = GenreActor()
        
        if !staticid.isNil {
            do {
                let genreRequest = try await MCatalog.genre(id: staticid!)
                await genreActor.set(genreRequest)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return await genreActor.genre
    }
}

