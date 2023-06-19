//
//  Defaults.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import Defaults

extension Defaults.Keys {
 // static let quality = Key<Double>("quality", default: 0.8)
   ///            ^                        ^                         ^                          ^
   ///           Key                    Type          UserDefaults name   Default value
 
    static let musicAccessEnabled = Key<Bool>("musicAccessEnabled", default: false)
    static let needsToSubscribe = Key<Bool>("needsToSubscribe", default: false)
    static let onboarded = Key<Bool>("onboarded", default: false)
    
    static let explicitAllowed = Key<Bool>("explicitAllowed", default: true)
    static let showBlockExplicitText = Key<Bool>("showBlockExplicitText", default: true)
}
