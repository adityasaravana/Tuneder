//
//  AVPlayerBufferStatusController.swift
//  Tuneder
//
//  Created by Aditya Saravana on 6/23/23.
//

import SwiftUI
import AVFoundation

class AVPlayerBufferStatusController: ObservableObject {
    @Published private(set) var isStall: Bool = false
    
    private var isPlaybackBufferEmptyObserver: NSKeyValueObservation?
    private var isPlaybackBufferFullObserver: NSKeyValueObservation?
    private var isPlaybackLikelyToKeepUpObserver: NSKeyValueObservation?
    
    init(playerItem: AVPlayerItem) {
        observeBuffering(for: playerItem)
    }
    
    private func observeBuffering(for playerItem: AVPlayerItem) {
        isPlaybackBufferEmptyObserver = playerItem.observe(\.isPlaybackBufferEmpty, options: [.initial, .new]) { [weak self] playerItem, _ in
            self?.onIsPlaybackBufferEmptyObserverChanged(playerItem: playerItem)
        }
        
        isPlaybackBufferFullObserver = playerItem.observe(\.isPlaybackBufferFull, options: [.initial, .new]) { [weak self] playerItem, _ in
            self?.onIsPlaybackBufferFullObserverChanged(playerItem: playerItem)
        }
        
        isPlaybackLikelyToKeepUpObserver = playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.initial, .new]) { [weak self] playerItem, _ in
            self?.onIsPlaybackLikelyToKeepUpObserverChanged(playerItem: playerItem)
        }
    }
    
    private func onIsPlaybackBufferEmptyObserverChanged(playerItem: AVPlayerItem) {
        if playerItem.isPlaybackBufferEmpty {
            isStall = true
        }
    }
    
    private func onIsPlaybackBufferFullObserverChanged(playerItem: AVPlayerItem) {
        if playerItem.isPlaybackBufferFull {
            isStall = false
        }
    }
    
    private func onIsPlaybackLikelyToKeepUpObserverChanged(playerItem: AVPlayerItem) {
        if playerItem.isPlaybackLikelyToKeepUp {
            isStall = false
        }
    }
}

