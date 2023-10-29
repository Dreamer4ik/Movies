//
//  MovieNoSearchResultsView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 27.10.2023.
//

import UIKit

protocol MovieNoSearchResultsViewDelegate: AnyObject {
    func didTapReturnButton()
}

class MovieNoSearchResultsView: UIView {
    // MARK: - Properties
    private let viewModel = MovieNoSearchResultsViewViewModel()
    weak var delegate: MovieNoSearchResultsViewDelegate?
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        return iconView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    private let returnButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        addSubviews(iconView, label, returnButton)
        
        iconView.center(inView: self)
        iconView.setDimensions(width: 90, height: 90)
        
        label.anchor(top: iconView.bottomAnchor, paddingTop: 10)
        label.centerX(inView: iconView)
        
        returnButton.centerX(inView: self)
        returnButton.anchor(top: label.bottomAnchor, paddingTop: 10)
        returnButton.setDimensions(width: 200, height: 30)
        returnButton.addTarget(self, action: #selector(didTapReturnButton) , for: .touchUpInside)
        
        configure()
    }
    
    private func configure() {
        label.text = viewModel.title
        iconView.image = viewModel.image
        returnButton.setTitle(viewModel.textButton, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func didTapReturnButton() {
        print("here")
        delegate?.didTapReturnButton()
    }
}
