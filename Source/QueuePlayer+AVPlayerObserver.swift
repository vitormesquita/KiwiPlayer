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
        timeObserver = currentPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main, using: { (timeInterval) in
            //TODO pegar os videos anteriores somar a duração mais o timeInteraval do video corrente
        })
    }
    
    internal func removePlayerObserver() {
        if let timeObserver = timeObserver {
            currentPlayer?.removeTimeObserver(timeObserver)
        }
    }
}

