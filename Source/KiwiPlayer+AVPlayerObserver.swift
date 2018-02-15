//
//  QueuePlayer+AVPlayerObserver.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - AVPlayer Observer
extension KiwiPlayer {
    
    internal func addPlayerObserver() {
        timeObserver = currentPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 2), queue: DispatchQueue.main, using: {[weak self] (time) in
            guard let strongSelf = self else { return }
            strongSelf.currentTime = time.seconds
        })
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            currentPlayer?.removeTimeObserver(timeObserver)
        }
    }
}

