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

open class QueuePlayer: NSObject {
    
    public var playerLayer: AVPlayerLayer
    public weak var delegate: QueuePlayerDelegate?
    
    internal var playerItems: [AVPlayerItem]
    internal var nextPlayer: AVPlayer?
    
    internal var currentItem: AVPlayerItem? {
        didSet {
            if let item = findNextElement(currentItem: currentItem) {
                self.nextPlayer = AVPlayer(playerItem: item.copy() as? AVPlayerItem)
            } else {
                self.nextPlayer = nil
            }
        }
    }
    
    internal var currentPlayer: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerItemRemoveObservers(playerLayer.player?.currentItem)
            
            newValue?.volume = volume
            newValue?.actionAtItemEnd = .pause
            
            playerLayer.player = newValue
            
            addPlayerItemObservers(newValue?.currentItem)
        }
    }
    
    internal var bufferingState: BufferingState = .unknown {
        didSet {
            delegate?.bufferingStateDidChange(bufferingState)
        }
    }
    
    internal var playbackState: PlaybackState = .stopped {
        didSet {
            delegate?.playbackStateDidChange(playbackState)
        }
    }
    
    internal var timeObserver: Any?
    
    public init(items: [URL]) {
        playerLayer = AVPlayerLayer()
        playerItems = items.map { AVURLAsset(url: $0) }.map { AVPlayerItem(asset: $0) }
        
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
        
        if let index = playerItems.index(of: currentItem), index + 1 < playerItems.count {
            return playerItems[index + 1]
        }
        return nil
    }
    
    internal func setPlayerFromBeginning() {
        currentItem = playerItems.first
        currentPlayer = AVPlayer(playerItem: playerItems.first!.copy() as? AVPlayerItem)
        currentPlayer?.seek(to: kCMTimeZero)
    }
}

// MARK: - Public
extension QueuePlayer {
    
    /// Total duration from all videos
    public var totalDuration: Float64 {
        get {
            let totalTime = playerItems.reduce(kCMTimeZero) { (total, item) -> CMTime in
                return CMTimeAdd(item.asset.duration, total)
            }
            return CMTimeGetSeconds(totalTime)
        }
    }
    
    /// Define volume to current video
    public var volume: Float {
        get {
            return currentPlayer?.volume ?? 1
        }
        set {
            currentPlayer?.volume = newValue
        }
    }
    
    /// Set `currentPlayer` with first item in queue
    public func playFromBeginnig() {
        setPlayerFromBeginning()
        play()
    }
    
    /// Play from current time and current video
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
    
    /// Stop queue and come back to first video
    public func stop() {
        guard playbackState != .stopped else { return }
        
        currentPlayer?.pause()
        setPlayerFromBeginning()
        playbackState = .stopped
    }
    
    /// Seek to current video that correspond at second indicates as parameter and extract second to seek in video
    public func seekTo(seconds: Float64) {
        
        var secondFormated = seconds
        var itemToSeek: AVPlayerItem?
        
        searchItemLoop: for item in playerItems {
            let secondsFromItem = CMTimeGetSeconds(item.asset.duration)
            
            let result = (secondFormated - secondsFromItem)
            
            if result > 0 {
                secondFormated = result
            } else {
                itemToSeek = item
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

