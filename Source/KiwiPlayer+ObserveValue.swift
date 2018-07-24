//
//  KiwiPlayer+ObserveValue.swift
//  KiwiPlayer
//
//  Created by Vitor Mesquita on 23/07/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

extension KiwiPlayer {
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        if let item = object as? AVPlayerItem, context == &playerItemContext {
            
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
        
        if let item = object as? AVPlayer, context == &playerContext {
            switch keyPath {
            case externalPlaybackActive:
                delegate?.playbackExternalChanged(item.isExternalPlaybackActive)
                
            default:
                break
            }
        }
    }
}
