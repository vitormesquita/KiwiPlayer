//
//  QueuePlayer+AVPlayerItemObservers.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

var playerItemContext = 0

let playbackBufferEmptyKey = "playbackBufferEmpty"
let playbackLikelyToKeepUpKey = "playbackLikelyToKeepUp"
let playbackBufferFullKey = "playbackBufferFull"
let playbackLoadedTimeRanges = "loadedTimeRanges"

// MARK: - AVPlayerItem observers
extension KiwiPlayer {
    
    internal func addPlayerItemObservers(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else { return }
        
        playerItem.addObserver(self, forKeyPath: playbackBufferEmptyKey, options: [.new, .old], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackLikelyToKeepUpKey, options: [.new, .old], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackBufferFullKey, options: [.new, .old], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackLoadedTimeRanges, options: [.new, .old], context: &playerItemContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    internal func playerItemRemoveObservers(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else { return }
        
        playerItem.removeObserver(self, forKeyPath: playbackBufferEmptyKey, context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: playbackLikelyToKeepUpKey, context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: playbackBufferFullKey, context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: playbackLoadedTimeRanges, context: &playerItemContext)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    @objc internal func playerItemDidPlayToEndTime(_ notification: Notification) {
        timePassed += currentItem?.asset.duration.seconds ?? 0
        
        if let nextItem = nextItem {
            currentItem = nextItem
            
//            player.seek(to: kCMTimeZero)
            
        } else {
            stop()
            delegate?.playbackQueueIsOver()
        }
    }
    
    @objc internal func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        playbackState = .failed
    }
}
