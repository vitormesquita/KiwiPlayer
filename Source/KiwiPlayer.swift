//
//  QueuePlayer.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

public protocol KiwiPlayerDelegate: class {
    func bufferingStateDidChange(_ bufferState: BufferingState)
    func playbackStateDidChange(_ playerState: PlaybackState)
    func playbackTimeDidChange(_ seconds: Double)
    func playbackQueueIsOver()
    
    func playbackExternalChanged(_ isActived: Bool)
}

public extension KiwiPlayerDelegate {
    
    func playbackExternalChanged(_ isActived: Bool) {
        // optional method
    }
}

public enum BufferingState {
    case unknown
    case delayed
    case ready
    case loaded
}

public enum PlaybackState {
    case loading
    case ready
    case playing
    case paused
    case stopped
    case failed
}

open class KiwiPlayer: NSObject {
    
    /// AVPlayerLayer to be inserted as `subLayer` in `UIView` as well as others views
    /// It's important to set it's frame layer to be showed correctly
    public var playerLayer: AVPlayerLayer
    
    /// QueuePlayer's delegate to notify when change something
    public weak var delegate: KiwiPlayerDelegate?
    
    /// Indicates a preferred pause player automatically when app resigning active.
    public var pauseWhenResigningActive: Bool = true
    
    /// Indicates a preferred pause player automatically when app enter in background.
    public var pauseWhenEnterBackground: Bool = true
    
    /// Indicates a preferred play automatically when app enter in foreground
    public var playWhenEnterForeground: Bool = true
    
    /// Indicates the desired limit of network bandwidth consumption for this item.
    public var preferredPeakBitRate: Double = 0 {
        didSet {
            currentItem?.preferredPeakBitRate = preferredPeakBitRate
        }
    }
    
    /// Indicates a preferred upper limit on the resolution of the video to be downloaded and rendered by the player.
    public var preferredMaximumResolution: CGSize = .zero {
        didSet {
            if #available(iOS 11.0, *) {
                currentItem?.preferredMaximumResolution = preferredMaximumResolution
            }
        }
    }
    
    /// It's the `playerLayer`'s video player
    internal var player: AVPlayer
    
    /// Video queue
    internal var itemsQueue: [AVPlayerItem] = []
    
    /// It's the time duration of all played videos, it will be incremented on `playerItemDidPlayToEndTime`
    internal var timePassed: Double = 0
    
    /// Current time of the current video being played by `currentPlayer`
    internal var currentTime: Double = 0 {
        didSet {
            let total = currentTime + timePassed
            delegate?.playbackTimeDidChange(total)
        }
    }
    
    /// It's the next item that will raplace the `currentItem` on player
    internal var nextItem: AVPlayerItem?
    
    /// Represent current `AVPlayerItem` in `itemsQueue` and buffers the next video on `nextPlayer`
    internal var currentItem: AVPlayerItem? {
        get { return player.currentItem }
        set {
            if let oldItem = currentItem {
                playerItemRemoveObservers(oldItem)
            }
            
            self.nextItem = findNextElement(currentItem: newValue)
            addPlayerItemObservers(newValue)
            
            newValue?.preferredPeakBitRate = preferredPeakBitRate
            if #available(iOS 11.0, *) {
                newValue?.preferredMaximumResolution = preferredMaximumResolution
            }
            
            player.replaceCurrentItem(with: newValue)
        }
    }
    
    /// Define buffering state from `currentItem`
    internal var bufferingState: BufferingState = .unknown {
        didSet {
            delegate?.bufferingStateDidChange(bufferingState)
        }
    }
    
    /// Definie playback state from `currentItem`
    internal var playbackState: PlaybackState = .stopped {
        didSet {
            delegate?.playbackStateDidChange(playbackState)
        }
    }
    
    /// KVO oberver to periodic time
    internal var timeObserver: Any?
    
    /// Array of AVPlayer obervers
    internal var playerObservers = [NSKeyValueObservation]()
    
    /// Array of AVPlayerItem observers
    internal var playerItemObservers = [NSKeyValueObservation]()
    
    //internal var playerLayerObserver: NSKeyValueObservation? TODO verify the necessity
    
    public override init() {
        playerLayer = AVPlayerLayer()
        player = AVPlayer()
        super.init()
        
        addPlayerObserver()
        addApplicationObservers()
        self.playerLayer.player = player
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removePlayerObserver()
        
        currentItem = nil
        delegate = nil
    }
    
    /// Find next AVPlayerItem on queue to is pre loading it
    internal func findNextElement(currentItem: AVPlayerItem?) -> AVPlayerItem? {
        guard let currentItem = currentItem else { return nil }
        
        if let index = itemsQueue.index(of: currentItem), index + 1 < itemsQueue.count {
            return itemsQueue[index + 1]
        }
        return nil
    }
    
    /// Set Queue at the beginning
    internal func setPlayerFromBeginning() {
        guard !itemsQueue.isEmpty else { fatalError("You need to setVideosURL before try to play") }
        currentItem = itemsQueue.first
        player.seek(to: .zero)
    }
}

// MARK: - Public
extension KiwiPlayer {
    
    /// Total duration from all videos in seconds
    public var totalDurationInSeconds: Float64 {
        get {
            let totalTime = itemsQueue.reduce(.zero) { (total, item) -> CMTime in
                return CMTimeAdd(item.asset.duration, total)
            }
            return totalTime.seconds
        }
    }
    
    /// Set the videos URLs in queue
    public func setVideosURL(_ videosURL: [URL]) {
        playbackState = .loading
        
        print("KIWIPLAYER ------> START SET VIDEOS")
        
        DispatchQueue.global(qos: .background).async {
            
            for url in videosURL {
                let asset = AVURLAsset(url: url, options: .none)
                let item = AVPlayerItem(asset: asset)
                self.itemsQueue.append(item)
            }
            
            DispatchQueue.main.async {
                self.setPlayerFromBeginning()
                self.playbackState = .ready
                print("KIWIPLAYER ------> END SET VIDEOS")
            }
        }
    }
    
    /// Set `currentPlayer` with first item in queue
    public func playFromBeginnig() {
        if currentItem != itemsQueue.first {
            setPlayerFromBeginning()
        }
        play()
    }
    
    /// Play current video
    public func play() {
        guard !itemsQueue.isEmpty else {
            fatalError("You need to call setVideosURL before try to play")
        }
        
        if playbackState == .stopped {
            setPlayerFromBeginning()
        }
        
        player.play()
        playbackState = .playing
    }
    
    /// Pause current video
    public func pause() {
        guard playbackState == .playing else { return }        
        player.pause()
        playbackState = .paused
    }
    
    /// Stop queue and come back to the first video
    public func stop() {
        guard playbackState != .stopped else { return }
        
        player.replaceCurrentItem(with: nil)
        playbackState = .stopped
    }
    
    /// Seek the video that corresponds to the seconds, passed as parameter, and finds out it's corresponding time (in seconds)
    public func seekTo(seconds: Double) {
        var secondFormated = seconds
        var itemToSeek: AVPlayerItem?
        
        timePassed = 0
        
        searchItemLoop: for item in itemsQueue {
            let secondsFromItem = item.asset.duration.seconds
            
            let result = (secondFormated - secondsFromItem)
            
            if result >= 0 {
                secondFormated = result
                timePassed += secondsFromItem
                
            } else {
                itemToSeek = item
                currentTime = secondFormated
                break searchItemLoop
            }
        }
        
        if let itemToSeek = itemToSeek {
            
            if itemToSeek != currentItem {
                currentItem = itemToSeek
            }
            
            currentItem?.seek(to: CMTime(seconds: secondFormated, preferredTimescale: CMTimeScale(kCMTimeMaxTimescale))) {[weak self] (finished) in
                guard let strongSelf = self else { return }
                strongSelf.play()
            }
        }
    }
}

extension KiwiPlayer {
    
    /// Define the audio volume to current video
    public var volume: Float {
        get { return player.volume }
        set { player.volume = newValue }
    }
    
    /// QueuePlayer's mute action
    public var isMuted: Bool {
        get { return player.isMuted }
        set { player.isMuted = newValue }
    }
    
    /// Enable player run with AirPlay connection
    public var enableExternalPlayback: Bool {
        get { return player.allowsExternalPlayback }
        set { player.allowsExternalPlayback = newValue }
    }
}
