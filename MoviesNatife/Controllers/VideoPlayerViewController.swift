//
//  VideoPlayerViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 30.10.2023.
//

import UIKit
import youtube_ios_player_helper

class VideoPlayerViewController: UIViewController {
    // MARK: - Properties
    private var playerView = YTPlayerView()
    private let videoId: String
    
    // MARK: - Lifecycle
    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .label
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(playerView)
        playerView.delegate = self
        playerView.frame = view.bounds
        playerView.load(withVideoId: videoId)
    }
}

// MARK: - YTPlayerViewDelegate
extension VideoPlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
}
