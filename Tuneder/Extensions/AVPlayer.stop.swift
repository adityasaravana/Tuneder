//
//  AVPlayer.stop.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import AVFoundation

// Just a simple function that "stops" an AVPlayer.
extension AVPlayer {
    func stop(){
        self.seek(to: CMTime.zero)
        self.pause()
    }
}
