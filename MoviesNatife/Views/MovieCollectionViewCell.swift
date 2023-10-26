//
//  MovieCollectionViewCell.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import UIKit

/// Single cell for a movie
final class MovieCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MovieCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
//        label.textColor = .secondaryLabel
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let ratingIcon: UIImageView = {
        let imageView = UIImageView()
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(
            systemName: "star.fill")?
            .withConfiguration(symbolConfiguration)
        imageView.image = image
        imageView.tintColor = .ratingIcon
        return imageView
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        genresLabel.text = nil
        ratingLabel.text = nil
        imageView.image = nil
    }
    
    // MARK: - Helpers
    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        setUpLayer()
        
        contentView.addSubviews(imageView, titleLabel, ratingIcon, ratingLabel, genresLabel)
        
        imageView.addConstraintsToFillView(self)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 12, paddingLeft: 10, paddingRight: 10)
        
        ratingIcon.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingBottom: 30, paddingRight: 30)
        
        ratingLabel.centerY(inView: ratingIcon)
        ratingLabel.anchor(left: ratingIcon.rightAnchor, bottom: contentView.bottomAnchor, paddingBottom: 30, paddingRight: 2)
        genresLabel.anchor(top: ratingLabel.topAnchor, left: titleLabel.leftAnchor, right: ratingIcon.leftAnchor, paddingRight: 8)
    }
    
    private func setUpLayer() {
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOffset = CGSize(width: -4, height: 4)
        contentView.layer.shadowOpacity = 0.3
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setUpLayer()
    }
    
        public func configure(with viewModel: MovieCollectionViewCellViewModel) {
            titleLabel.text = "\(viewModel.movieTitleText)"
            ratingLabel.text = "\(viewModel.rating)"
            
    
            viewModel.fetchImage { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            viewModel.fetchGenres { [weak self] result in
                switch result {
                case .success(let model):
                    let matchingGenres = model.genres.filter { genre in
                        return viewModel.genreIDS.contains(genre.id)
                    }
                    let matchingGenreNames = matchingGenres.map { $0.name }
                    let genreNames: String
                    if !matchingGenreNames.isEmpty {
                        genreNames = matchingGenreNames.joined(separator: ", ")
                        
                    } else {
                        genreNames = "No Genre"
                    }
                    
                    DispatchQueue.main.async {
                        self?.genresLabel.text = "\(genreNames)"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
}
