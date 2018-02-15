//
//  ViewController.swift
//  QueuePlayer
//
//  Created by Vitor Mesquita on 14/02/2018.
//  Copyright © 2018 Vitor Mesquita. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var slider: UISlider!
    
    let urlString: [String] = ["http://player.vimeo.com/external/248598659.sd.mp4?s=8c65501f9c0fa68dad822b5e01fbae13fdefbe99&profile_id=165&oauth2_token_id=1029745847",
                               "http://player.vimeo.com/external/250052960.hd.mp4?s=9042ec29bf99314249e9fd705389148597fcea27&profile_id=174&oauth2_token_id=1029745847",
                               "http://player.vimeo.com/external/250052986.sd.mp4?s=9820d07a13ef83b4d497c92906cda4870c02cbbe&profile_id=164&oauth2_token_id=1029745847",
                               "http://player.vimeo.com/external/248599675.sd.mp4?s=41a30b1601356596a20c6c1cf3945caec816a08c&profile_id=164&oauth2_token_id=1029745847"]

    var items: [URL] = []
    var queuePlayer: QueuePlayer = QueuePlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        items = urlString
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { $0! }
        
        queuePlayer.setVideosURL(items)
        queuePlayer.delegate = self
        queuePlayer.playFromBeginnig()
        view.layer.addSublayer(queuePlayer.playerLayer)
        
        
        slider.maximumValue = Float(queuePlayer.totalDurationInSeconds)
        
        print(slider.maximumValue)
        print(queuePlayer.totalDurationInSeconds)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        queuePlayer.playerLayer.frame = view.frame
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        queuePlayer.seekTo(seconds: Float64(slider.value))
    }
}

extension ViewController: QueuePlayerDelegate {
    func playbackTimeDidChange(_ seconds: Float64) {
//        print(seconds)
        slider.value = Float(seconds)
    }
    
    func bufferingStateDidChange(_ bufferState: BufferingState) {
        
    }
    
    func playbackStateDidChange(_ playerState: PlaybackState) {
        
    }
    
    func playbackQueueIsOver() {
        
    }
    
    
}
