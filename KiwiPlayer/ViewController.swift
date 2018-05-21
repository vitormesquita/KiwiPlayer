//
//  ViewController.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    let urlString: [String] = [
        "http://techslides.com/demos/sample-videos/small.mp4"
    ]

    var items: [URL] = []
    var queuePlayer: KiwiPlayer = KiwiPlayer()
    
//    let routerPickerView = AVRoutePickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        items = urlString
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { $0! }
        
        queuePlayer.setVideosURL(items)
        queuePlayer.delegate = self
        queuePlayer.playFromBeginnig()
        view.layer.addSublayer(queuePlayer.playerLayer)
        
        slider.maximumValue = Float(queuePlayer.totalDurationInSeconds)
        
//        routerPickerView.activeTintColor = .red
//        routerPickerView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(routerPickerView)
//        routerPickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
//        routerPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
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
}
