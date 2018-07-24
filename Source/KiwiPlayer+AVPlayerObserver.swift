//
//  QueuePlayer+AVPlayerObserver.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

var playerContext = 1
let externalPlaybackActive = "externalPlaybackActive"

// MARK: - AVPlayer Observer
extension KiwiPlayer {
    
    internal func addPlayerObserver() {
        timeObserver = currentPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main, using: {[weak self] (time) in
            guard let strongSelf = self else { return }
            strongSelf.currentTime = time.seconds
        })
        
        currentPlayer.addObserver(self, forKeyPath: externalPlaybackActive, options: NSKeyValueObservingOptions.new, context: &playerContext)
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            currentPlayer.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        currentPlayer.removeObserver(self, forKeyPath: externalPlaybackActive, context: &playerContext)
    }
}
