//
//  Song.backgroundColorSwiftUI.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import SwiftUI
import MusicKit

extension Song {
    var backgroundColorSwiftUI: Color {
        if let artwork = self.artwork {
            if let background = artwork.backgroundColor {
                return Color(background)
            } else {
                return Color.pink
            }
        } else {
            return Color.blue
        }
        // return Color(self.artwork?.backgroundColor ?? UIColor.lightGray.cgColor)
    }
}
