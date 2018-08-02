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
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: {[weak self] (time) in
            guard let strongSelf = self else { return }
            if strongSelf.player.currentItem?.status == .readyToPlay {
                
                // MARK: - Workaround for AirPlay connection cause `addPeriodicTimeObserver` was not returning the correct time :(
                if time.seconds < strongSelf.timeDelayedExternal && strongSelf.timeDelayedExternal != 0 && strongSelf.player.isExternalPlaybackActive {
                    let time = CMTime(seconds: strongSelf.timeDelayedExternal, preferredTimescale: CMTimeScale(kCMTimeMaxTimescale))
                    strongSelf.player.seek(to: time)
                    strongSelf.timeDelayedExternal = 0
                    
                } else {
                    strongSelf.currentTime = time.seconds
                }
                
                print(strongSelf.currentTime)
            }
        })
        
        player.addObserver(self, forKeyPath: externalPlaybackActive, options: [.new, .old], context: &playerContext)
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        player.removeObserver(self, forKeyPath: externalPlaybackActive, context: &playerContext)
    }
}
