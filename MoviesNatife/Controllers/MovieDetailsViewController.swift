//
//  MovieDetailsViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

/// Controller to show info about single movie
final class MovieDetailsViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MovieDetailViewViewModel
    private let detailView: MovieDetailView
    
    // MARK: - Lifecycle
    init(viewModel: MovieDetailViewViewModel) {
        self.viewModel = viewModel
        self.detailView = MovieDetailView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        detailView.scrollView.fitSizeOfContent()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.title
        Utilities.configureNavBar(vc: self)
        
        view.addSubview(detailView)
        detailView.anchor(top: view.topAnchor, left: view.leftAnchor,bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: navigationBarBottom)
        detailView.delegate = self
    }
    
}

// MARK: - MovieDetailViewDelegate
extension MovieDetailsViewController: MovieDetailViewDelegate {
    func didTapImage(image: UIImage) {
        DispatchQueue.main.async {
            let vc = ImageViewController(image: image)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func didTapTrailerButton() {
        if let videoId = extractVideoId(from: viewModel.trailerURL) {
            let vc = VideoPlayerViewController(videoId: videoId)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func extractVideoId(from url: URL?) -> String? {
        guard let urlString = url?.absoluteString, let range = urlString.range(of: "v=") else {
            return nil
        }
        let videoId = urlString[range.upperBound...]
        return String(videoId)
    }
}
