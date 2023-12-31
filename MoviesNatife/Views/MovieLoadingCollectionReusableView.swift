//
//  MovieLoadingCollectionReusableView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 25.10.2023.
//

import UIKit

class MovieLoadingCollectionReusableView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "MovieLoadingCollectionReusableView"
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubview(spinner)
        spinner.center(inView: self)
        spinner.setDimensions(width: 100, height: 100)
    }
    
    public func startAnimating() {
        spinner.startAnimating()
    }
}
