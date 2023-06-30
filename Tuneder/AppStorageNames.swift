//
//  AppStorageNames.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/28/23.
//

import Foundation

/// Helps stay consistent between UserDefaults, Defaults, and @AppStorage
public enum AppStorageNames {
    case explicitContentAllowed
    case showExplicitContentWarning
    
    var name: String {
        switch self {
        case .explicitContentAllowed:
            return "tunederexplicitcontentallowed"
        case .showExplicitContentWarning:
            return "tunedershowexplicitcontentwarning"
        }
    }
}
