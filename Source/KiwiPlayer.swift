//
//  QueuePlayer.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVFoundation

public protocol QueuePlayerDelegate: class {
    func bufferingStateDidChange(_ bufferState: BufferingState)
    func playbackStateDidChange(_ playerState: PlaybackState)
    func playbackTimeDidChange(_ seconds: Float64)
    func playbackQueueIsOver()
}

public enum BufferingState {
    case unknown
    case delayed
    case ready
    case loaded
}

public enum PlaybackState {
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
    public weak var delegate: QueuePlayerDelegate?
    
    /// Video queue
    internal var itemsQueue: [AVPlayerItem] = []
    
    /// It's the next player that will raplace the `currentPlayer`
    internal var nextPlayer: AVPlayer?
    
    internal var timeObserver: Any?
    
    /// It's the time duration of all played videos, it will be incremented on `playerItemDidPlayToEndTime`
    internal var timePassed: Float64 = 0
    
    /// Current time of the current video being played by `currentPlayer`
    internal var currentTime: Float64 = 0 {
        didSet {
            delegate?.playbackTimeDidChange(currentTime + timePassed)
        }
    }
    
    /// Represent current `AVPlayerItem` in `itemsQueue` and buffers the next video on `nextPlayer`
    internal var currentItem: AVPlayerItem? {
        didSet {
            if let item = findNextElement(currentItem: currentItem) {
                self.nextPlayer = AVPlayer(playerItem: item.copy() as? AVPlayerItem)
            } else {
                self.nextPlayer = nil
            }
        }
    }
    
    /// It's the current `playerLayer`'s video player
    internal var currentPlayer: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerItemRemoveObservers(playerLayer.player?.currentItem)
            
            newValue?.volume = volume
            newValue?.actionAtItemEnd = .pause
            
            playerLayer.player = newValue
            
            addPlayerObserver()
            addPlayerItemObservers(newValue?.currentItem)
        }
    }
    
    ///
    internal var bufferingState: BufferingState = .unknown {
        didSet {
            delegate?.bufferingStateDidChange(bufferingState)
        }
    }
    
    ///
    internal var playbackState: PlaybackState = .stopped {
        didSet {
            delegate?.playbackStateDidChange(playbackState)
        }
    }
    
    public override init() {
        playerLayer = AVPlayerLayer()
        
        super.init()
        
        addApplicationObservers()
    }
    
    deinit {
        removeApplicationObservers()
        removePlayerObserver()
        
        currentPlayer = nil
        currentItem = nil
        delegate = nil
    }
    
    internal func findNextElement(currentItem: AVPlayerItem?) -> AVPlayerItem? {
        guard let currentItem = currentItem else { return nil }
        
        if let index = itemsQueue.index(of: currentItem), index + 1 < itemsQueue.count {
            return itemsQueue[index + 1]
        }
        return nil
    }
    
    internal func setPlayerFromBeginning() {
        currentItem = itemsQueue.first
        currentPlayer = AVPlayer(playerItem: itemsQueue.first!.copy() as? AVPlayerItem)
        currentPlayer?.seek(to: kCMTimeZero)
    }
}

// MARK: - Public
extension KiwiPlayer {
    
    /// Total duration from all videos in seconds
    public var totalDurationInSeconds: Float64 {
        get {
            let totalTime = itemsQueue.reduce(kCMTimeZero) { (total, item) -> CMTime in
                return CMTimeAdd(item.asset.duration, total)
            }
            return totalTime.seconds
        }
    }
    
    /// Define the audio volume to current video
    public var volume: Float {
        get {
            return currentPlayer?.volume ?? 1
        }
        set {
            currentPlayer?.volume = newValue
        }
    }
    
    /// Set the videos URLs in queue
    public func setVideosURL(_ videosURL: [URL]) {
        itemsQueue = videosURL.map { AVURLAsset(url: $0) }.map { AVPlayerItem(asset: $0) }
    }
    
    /// Set `currentPlayer` with first item in queue
    public func playFromBeginnig() {
        setPlayerFromBeginning()
        play()
    }
    
    /// Play current video
    public func play() {
        currentPlayer?.play()
        playbackState = .playing
    }
    
    /// Pause current video
    public func pause() {
        guard playbackState == .playing else { return }
        
        currentPlayer?.pause()
        playbackState = .paused
    }
    
    /// Stop queue and come back to the first video
    public func stop() {
        guard playbackState != .stopped else { return }
        
        currentPlayer?.pause()
        setPlayerFromBeginning()
        playbackState = .stopped
    }
    
    /// Seek the video that corresponds to the seconds, passed as parameter, and finds out it's corresponding time (in seconds)
    public func seekTo(seconds: Float64) {
        
        var secondFormated = seconds
        var itemToSeek: AVPlayerItem?
        
        timePassed = 0
        
        searchItemLoop: for item in itemsQueue {
            let secondsFromItem = CMTimeGetSeconds(item.asset.duration)
            
            let result = (secondFormated - secondsFromItem)
            
            if result > 0 {
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
                currentPlayer = AVPlayer(playerItem: itemToSeek.copy() as? AVPlayerItem)
            }

            currentPlayer?.seek(to: CMTime(seconds: secondFormated, preferredTimescale: CMTimeScale(kCMTimeMaxTimescale)))
            play()
        }
    }
}
