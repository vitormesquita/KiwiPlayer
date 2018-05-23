//
//  QueuePlayer+AVPlayerItemObservers.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate var playerItemContext = 0

fileprivate let playbackBufferEmptyKey = "playbackBufferEmpty"
fileprivate let playbackLikelyToKeepUpKey = "playbackLikelyToKeepUp"
fileprivate let playbackBufferFullKey = "playbackBufferFull"
fileprivate let playbackLoadedTimeRanges = "loadedTimeRanges"

// MARK: - AVPlayerItem observers
extension KiwiPlayer {
    
    internal func addPlayerItemObservers(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else { return }
        
        playerItem.addObserver(self, forKeyPath: playbackBufferEmptyKey, options: [] /*[.new, .old]*/, context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackLikelyToKeepUpKey, options: [] /*[.new, .old]*/, context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackBufferFullKey, options: [] /*[.new, .old]*/, context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: playbackLoadedTimeRanges, options: [] /*[.new, .old]*/, context: &playerItemContext)
        
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
        timePassed += currentPlayer?.currentTime().seconds ?? 0
        
        guard let player = currentPlayer, let currentDuration = player.currentItem?.duration,
            player.currentTime().seconds >= currentDuration.seconds else {
                return
        }
        
        if let nextPlayer = nextPlayer {
            currentPlayer = nextPlayer
            currentItem = findNextElement(currentItem: currentItem)
            play()
            
        } else {
            delegate?.playbackQueueIsOver()
            stop()
        }
    }
    
    @objc internal func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        playbackState = .failed
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, context == &playerItemContext else { return }
        
        if let item = object as? AVPlayerItem {
            
            if item.status == .failed {
                playbackState = .failed
                return
            }
            
            switch keyPath {
            case playbackBufferEmptyKey:
                if item.isPlaybackBufferEmpty {
                    bufferingState = .delayed
                }
                
            case playbackLikelyToKeepUpKey:
                if item.isPlaybackLikelyToKeepUp {
                    bufferingState = .ready
                }
                
            case playbackLoadedTimeRanges:
                bufferingState = .ready
                
            case playbackBufferFullKey:
                bufferingState = .loaded
                
            default:
                break
            }
        }
    }
}

