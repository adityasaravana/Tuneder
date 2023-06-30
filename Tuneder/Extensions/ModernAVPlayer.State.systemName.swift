//
//  ModernAVPlayer.State.systemName.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/29/23.
//

import ModernAVPlayer

extension ModernAVPlayer.State {
    func systemName() -> String? {
        switch self {
        case .buffering, .loading, .initialization, .waitingForNetwork:
            return nil
        case .paused, .loaded:
            return "play.fill"
        case .playing:
            return "pause.fill"
        case .failed, .stopped:
            return "xmark.diamond.fill"
        }
    }
}
