//
//  ViewController.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

struct Time {
    let hours: Int
    let minutes: Int
    let seconds: Int
}

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var maxTimeLabel: UILabel!
    
    let urlString: [String] = [
        "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4",
        "http://player.vimeo.com/external/248598659.sd.mp4?s=8c65501f9c0fa68dad822b5e01fbae13fdefbe99&profile_id=165&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/254938108.sd.mp4?s=0ea1dcf09bb82c8a3961044ddcb6af0b203f46ad&profile_id=164&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/249347540.sd.mp4?s=1ea7c950db8d0cfbdc9549a5a519c884b8bf9adb&profile_id=164&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/254937438.hd.mp4?s=3270a2915b362a59e681b50e62c89f0e811ecbd9&profile_id=175&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/248599675.sd.mp4?s=41a30b1601356596a20c6c1cf3945caec816a08c&profile_id=164&oauth2_token_id=1029745847"
    ]

    var items: [URL] = []
    var queuePlayer: KiwiPlayer = KiwiPlayer()
    
    let routerPickerView = AVRoutePickerView()
    var isloaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        items = urlString.compactMap { URL(string: $0) }
        
        queuePlayer.setVideosURL(items)
        queuePlayer.enableExternalPlayback = true
        queuePlayer.delegate = self

        view.layer.insertSublayer(queuePlayer.playerLayer, at: 0)
        
        slider.maximumValue = Float(queuePlayer.totalDurationInSeconds)
        
        routerPickerView.activeTintColor = .red
        routerPickerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(routerPickerView)
        routerPickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        routerPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isloaded {
            queuePlayer.playFromBeginnig()
            isloaded = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        queuePlayer.playerLayer.frame = view.frame
    }
    
    @objc private func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                break
                
            case .ended:
                queuePlayer.seekTo(seconds: Double(slider.value))
                
            default:
                break
            }
        }
    }
    
    @IBAction func muteButtonAction(_ sender: Any) {
        queuePlayer.isMuted = !queuePlayer.isMuted
    }
    
     func secondsToHoursMinutesSeconds(seconds: Int) -> Time {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return Time(hours: hours, minutes: minutes, seconds: seconds)
    }
}

extension ViewController: KiwiPlayerDelegate {
    func playbackTimeDidChange(_ seconds: Double) {
        slider.value = Float(seconds)
        
        let time = secondsToHoursMinutesSeconds(seconds: Int(seconds))
        if time.hours > 0 {
            currentTimeLabel.text = String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds)
        } else {
            currentTimeLabel.text = String(format: "%02d:%02d", time.minutes, time.seconds)
        }
    }
    
    func bufferingStateDidChange(_ bufferState: BufferingState) {
        
    }
    
    func playbackStateDidChange(_ playerState: PlaybackState) {
        
    }
    
    func playbackQueueIsOver() {
        
    }
    
    func playbackExternalChanged(_ isActived: Bool) {
    }
}
