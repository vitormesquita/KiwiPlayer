//
//  QueuePlayer+ApplicationObservers.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit

// MARK: - Application Observers
extension KiwiPlayer {
    
    internal func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)
    }
    
    @objc internal func applicationWillResignActive(_ aNotification: Notification) {
        if playbackState == .playing && pauseWhenResigningActive {
            pause()
        }
    }
    
    @objc internal func applicationDidBecomeActive(_ aNotification: Notification) {
        if playbackState != .playing && playWhenEnterForeground {
            play()
        }
    }
    
    @objc internal func applicationDidEnterBackground(_ aNotification: Notification) {
        if playbackState == .playing && pauseWhenEnterBackground {
            pause()
        }
    }
    
    @objc internal func applicationWillEnterForeground(_ aNoticiation: Notification) {
        if playbackState != .playing && playWhenEnterForeground {
            play()
        }
    }
}
