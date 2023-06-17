//
//  AVPlayer.stop.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/16/23.
//

import AVFoundation

extension AVPlayer {
    func stop(){
        self.seek(to: CMTime.zero)
        self.pause()
    }
}
