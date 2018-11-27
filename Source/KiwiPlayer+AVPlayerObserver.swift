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
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (time) in
            guard let strongSelf = self else { return }
            if strongSelf.player.currentItem?.status == .readyToPlay {
                strongSelf.currentTime = time.seconds
            }
        })
        
        playerObservers.append(player.observe(\.isExternalPlaybackActive, options: [.new, .old]) {[weak self] (player, change) in
            guard let self = self else { return }
            self.delegate?.playbackExternalChanged(player.isExternalPlaybackActive)
        })
        
//        if #available(iOS 10.0, *) {
//            self.playerObservers.append(self.player.observe(\.timeControlStatus, options: [.new, .old]) {[weak self] (player, change) in
//                guard let self = self else { return }
//                switch player.timeControlStatus {
//                case .paused:
//                    self.playbackState = .paused
//                case .playing:
//                    self.playbackState = .playing
//                case .waitingToPlayAtSpecifiedRate:
//                    break
//                }
//            })
//        }
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        for observer in playerObservers {
            observer.invalidate()
        }
        
        playerObservers.removeAll()
    }
}
