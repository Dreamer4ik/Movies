//
//  MovieDetailView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit
import SDWebImage

protocol MovieDetailViewDelegate: AnyObject {
    func didTapTrailerButton()
    func didTapImage(image: UIImage)
}

/// View for a single movie into
final class MovieDetailView: UIView {
    // MARK: - Properties
    weak var delegate: MovieDetailViewDelegate?
    private let viewModel: MovieDetailViewViewModel
    
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let yearAndCountryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let trailerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.tintColor = .white
        button.layer.cornerRadius = 8
        let image = UIImage(systemName: "play.rectangle.fill")
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        button.setImage(image?.withConfiguration(config), for: .normal)
        return button
    }()
    
    //    private let spinner: UIActivityIndicatorView = {
    //        let spinner = UIActivityIndicatorView(style: .large)
    //        spinner.hidesWhenStopped = true
    //        return spinner
    //    }()
    
    // MARK: - Lifecycle
    init(frame: CGRect, viewModel: MovieDetailViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .systemBackground
        
        addSubview(scrollView)
        scrollView.addConstraintsToFillView(self)
        
        scrollView.addSubviews(posterImageView, titleLabel, yearAndCountryLabel, genresLabel, trailerButton, ratingLabel, descriptionLabel)
        
        posterImageView.centerX(inView: self)
        posterImageView.anchor(top: scrollView.topAnchor, paddingTop: 10, width: 320, height: 400)
        
        titleLabel.anchor(top: posterImageView.bottomAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        yearAndCountryLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 16)
        
        genresLabel.anchor(top: yearAndCountryLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16)
        
        let sizeButton: CGFloat = 32
        trailerButton.anchor(top: genresLabel.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 16, width: sizeButton, height: sizeButton)
        trailerButton.layer.cornerRadius = sizeButton/2
        
        ratingLabel.centerY(inView: trailerButton)
        ratingLabel.anchor(right: rightAnchor, paddingRight: 16)
        
        descriptionLabel.anchor(top: trailerButton.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16)
        
        trailerButton.addTarget(self, action: #selector(didTapTrailerButton), for: .touchUpInside)
        addGesture()
        SetUpData()
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        posterImageView.addGestureRecognizer(tapGesture)
        posterImageView.isUserInteractionEnabled = true
    }
    
    private func SetUpData() {
        titleLabel.text = viewModel.title
        yearAndCountryLabel.text = viewModel.countryAndYear
        genresLabel.text = viewModel.genres
        ratingLabel.text = "\(BaseConstants.Localization.rating): \(viewModel.roundedRating)"
        descriptionLabel.text = viewModel.descriptionText
        
        trailerButton.isHidden = viewModel.trailerButtonIsHidden
        
        posterImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
    // MARK: - Actions
    @objc private func didTapTrailerButton() {
        delegate?.didTapTrailerButton()
    }
    
    @objc private func didTapImage() {
        guard let image = posterImageView.image else { return }
        delegate?.didTapImage(image: image)
    }
}
