//
//  Defaults.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/17/23.
//

import Defaults

// This is the data storage for all the settings and user preferences of the app, using the Defaults package. Find out more at the GitHub repository: https://github.com/sindresorhus/Defaults


extension Defaults.Keys {
    static let explicitContentAllowed = Key<Bool>("explicitContentAllowed", default: true)
    static let showExplicitContentWarning = Key<Bool>("showExplicitContentWarning", default: true)
    static let musicAccessEnabled = Key<Bool>("musicAccessEnabled", default: false)
}
