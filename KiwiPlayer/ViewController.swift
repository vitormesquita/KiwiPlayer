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

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    let urlString: [String] = [
        "http://techslides.com/demos/sample-videos/small.mp4",
        "http://player.vimeo.com/external/248598659.sd.mp4?s=8c65501f9c0fa68dad822b5e01fbae13fdefbe99&profile_id=165&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/254938108.sd.mp4?s=0ea1dcf09bb82c8a3961044ddcb6af0b203f46ad&profile_id=164&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/254937501.hd.mp4?s=3029bbe710bc23a888f00b1dc68aab95fd161fa7&profile_id=175&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/254937438.hd.mp4?s=3270a2915b362a59e681b50e62c89f0e811ecbd9&profile_id=175&oauth2_token_id=1029745847",
        "http://player.vimeo.com/external/248599675.sd.mp4?s=41a30b1601356596a20c6c1cf3945caec816a08c&profile_id=164&oauth2_token_id=1029745847"
    ]

    var items: [URL] = []
    var queuePlayer: KiwiPlayer = KiwiPlayer()
    
    let routerPickerView = AVRoutePickerView()
    var isloaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        items = urlString
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { $0! }
        
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
    
    @IBAction func sliderAction(_ sender: Any) {
        queuePlayer.seekTo(seconds: Float64(slider.value))
    }
    
    @IBAction func muteButtonAction(_ sender: Any) {
        queuePlayer.isMuted = !queuePlayer.isMuted
    }
}

extension ViewController: KiwiPlayerDelegate {
    func playbackTimeDidChange(_ seconds: Float64) {
        slider.value = Float(seconds)
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
