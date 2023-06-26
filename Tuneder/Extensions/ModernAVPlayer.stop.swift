//
//  AVPlayer.stop.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import ModernAVPlayer
import AVFoundation

// Just a simple function that "stops" an AVPlayer.
extension ModernAVPlayer {
    func stop() {
        self.player.seek(to: CMTime.zero)
        self.pause()
    }
}
