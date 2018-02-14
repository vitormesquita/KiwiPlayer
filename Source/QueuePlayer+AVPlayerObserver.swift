//
//  QueuePlayer+AVPlayerObserver.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

extension QueuePlayer {
    
    internal func addPlayerObserver() {
        timeObserver = currentPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main, using: {[weak self] (time) in
            guard let strongSelf = self else { return }
            //TODO pegar os videos anteriores somar a duração mais o timeInteraval do video corrente
            var totalSeconds: Float64 = 0
            
            searchItemLoop: for item in strongSelf.playerItems {
                let secondsFromItem = CMTimeGetSeconds(item.asset.duration)
                
                if item == strongSelf.currentItem {
                    totalSeconds += CMTimeGetSeconds(time)
                    break searchItemLoop
            
                } else {
                    totalSeconds += secondsFromItem
                }
            }
            
            strongSelf.delegate?.playbackTimeDidChange(totalSeconds)
        })
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            currentPlayer?.removeTimeObserver(timeObserver)
        }
    }
}

