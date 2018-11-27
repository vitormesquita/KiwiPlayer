//
//  QueuePlayer+AVPlayerItemObservers.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - AVPlayerItem observers
extension KiwiPlayer {
    
    internal func addPlayerItemObservers(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        
        playerItemObservers.append(playerItem.observe(\.isPlaybackBufferEmpty, options: [.new, .old]) {[weak self] (item, change) in
            guard let self = self else { return }
            
            if item.isPlaybackBufferEmpty {
                self.bufferingState = .delayed
            }
            
            switch item.status {
            case .failed:
                self.playbackState = .failed
            default:
                break
            }
        })
        
        self.playerItemObservers.append(playerItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new, .old]) {[weak self] (item, change) in
            guard let self = self else { return }
            
            if item.isPlaybackLikelyToKeepUp {
                self.bufferingState = .ready
                
                if self.playbackState == .playing {
                    self.play()
                }
            }
            
            switch item.status {
            case .failed:
                self.playbackState = .failed
            default:
                break
            }
        })
        
        self.playerItemObservers.append(playerItem.observe(\.loadedTimeRanges, options: [.new, .old]) {[weak self] (item, change) in
            guard let self = self else { return }
            
            self.bufferingState = .ready
            
            //            let timeRanges = item.loadedTimeRanges
            //            if let timeRange = timeRanges.first?.timeRangeValue {
            //                let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
            //                if strongSelf._lastBufferTime != bufferedTime {
            //                    strongSelf._lastBufferTime = bufferedTime
            //                    strongSelf.executeClosureOnMainQueueIfNecessary {
            //                        strongSelf.playerDelegate?.playerBufferTimeDidChange(bufferedTime)
            //                    }
            //                }
            //            }
            //
            //            let currentTime = CMTimeGetSeconds(object.currentTime())
            //            let passedTime = strongSelf._lastBufferTime <= 0 ? currentTime : (strongSelf._lastBufferTime - currentTime)
            //
            //            if (passedTime >= strongSelf.bufferSizeInSeconds ||
            //                strongSelf._lastBufferTime == strongSelf.maximumDuration ||
            //                timeRanges.first == nil) &&
            //                strongSelf.playbackState == .playing {
            //                strongSelf.play()
            //            }
        })
        
        self.playerItemObservers.append(playerItem.observe(\.isPlaybackBufferFull, options: [.new, .old]) {[weak self] (item, change) in
            guard let self = self else { return }
            self.bufferingState = .loaded
        })
    }
    
    internal func playerItemRemoveObservers(_ playerItem: AVPlayerItem?) {
        guard let playerItem = playerItem else { return }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        
        for observer in playerItemObservers {
            observer.invalidate()
        }
        
        playerItemObservers.removeAll()
    }
    
    @objc internal func playerItemDidPlayToEndTime(_ notification: Notification) {
        timePassed += currentItem?.asset.duration.seconds ?? 0
        
        if let nextItem = nextItem {
            currentItem = nextItem
            
            currentItem?.seek(to: .zero) {[weak self] (finished) in
                guard let self = self, finished else { return }
                self.play()
            }
            
        } else {
            stop()
            delegate?.playbackQueueIsOver()
        }
    }
    
    @objc internal func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        playbackState = .failed
    }
}
