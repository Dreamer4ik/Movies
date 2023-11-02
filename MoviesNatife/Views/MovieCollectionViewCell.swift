//
//  MovieCollectionViewCell.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import UIKit
import SDWebImage

/// Single cell for a movie
final class MovieCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MovieCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
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
        contentView.layer.cornerRadius = 8
        setUpLayer()
        
        contentView.addSubviews(imageView, titleLabel, ratingIcon, ratingLabel, genresLabel)
        
        imageView.addConstraintsToFillView(self)
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 12, paddingLeft: 10, paddingRight: 10)
        
        ratingIcon.anchor(bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingBottom: 30, paddingRight: 35)
        
        ratingLabel.centerY(inView: ratingIcon)
        ratingLabel.anchor(left: ratingIcon.rightAnchor, bottom: contentView.bottomAnchor, paddingBottom: 30, paddingRight: 2)
        genresLabel.anchor(top: ratingLabel.topAnchor, left: titleLabel.leftAnchor, right: ratingIcon.leftAnchor, paddingRight: 8)
        
        addGradient()
    }
    
    private func setUpLayer() {
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowPath = UIBezierPath(rect: contentView.bounds).cgPath
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func addGradient() {
        configureTopGradientLayer()
        configureBottomGradientLayer()
    }
    
    private func configureTopGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height * 0.15)
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 1]
        imageView.layer.addSublayer(gradientLayer)
    }
    
    private func configureBottomGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: contentView.bounds.height * 0.85, width: contentView.bounds.width, height: contentView.bounds.height * 0.15)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 1]
        imageView.layer.addSublayer(gradientLayer)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setUpLayer()
    }
    
    public func configure(with viewModel: MovieCollectionViewCellViewModel) {
        titleLabel.text = "\(viewModel.movieTitleText)"
        ratingLabel.text = "\(viewModel.roundedRating)"
        imageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        
        if Network.reachability?.isReachable == false {
            let apiGenreIDs = viewModel.genreIDS
            let genresList = OfflineGenres.genresList
            let apiGenreNames = genresList.filter { genre in
                return apiGenreIDs.contains(genre.id)
            }.map { $0.name.localized() }
            
            genresLabel.text = apiGenreNames.joined(separator: ", ")
        } else {
            viewModel.fetchGenres { [weak self] result in
                switch result {
                case .success(let model):
                    let matchingGenres = model.genres.filter { genre in
                        return viewModel.genreIDS.contains(genre.id)
                    }
                    let matchingGenreNames = matchingGenres.map { $0.name.localized() }
                    let genreNames: String
                    if !matchingGenreNames.isEmpty {
                        genreNames = matchingGenreNames.joined(separator: ", ")
                        
                    } else {
                        genreNames = BaseConstants.Localization.noGenre
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
}
