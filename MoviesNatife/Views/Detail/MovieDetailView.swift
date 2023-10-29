//
//  MovieDetailView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

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
        imageView.image = UIImage(systemName: "photo.artframe")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "Film Title"
        label.numberOfLines = 2
        return label
    }()
    
    private let yearAndCountryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "US, 2031"
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.text = "Comedy"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vulputate eros ac nisi imperdiet, sit amet tristique turpis tristique. Donec non accumsan felis, ac finibus turpis. Quisque lectus ante, viverra sit amet lacus pulvinar, dignissim lacinia nisl. Morbi et nibh ac mauris condimentum fermentum a pretium ligula. Nam aliquam ullamcorper nisi, sed vulputate lectus luctus a. Ut auctor nisl id libero rutrum molestie. Etiam ut est vel quam lobortis lacinia quis a nulla.  Etiam viverra pharetra interdum. Maecenas in velit risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam tempus aliquet erat, non pellentesque erat porttitor sed. In pulvinar eleifend mi a tristique. Pellentesque dui elit, interdum pharetra vehicula sodales, gravida quis dolor. Integer placerat diam mi, et ultricies purus tincidunt et. Sed viverra ipsum lacus, tempor fringilla massa facilisis a. Proin orci tortor, mollis ut sem et, pharetra mollis nisi. Nullam elementum justo nec tortor egestas hendrerit ut vitae massa. Vestibulum sollicitudin, sem quis tincidunt aliquet, est quam varius purus, eget pellentesque dolor enim in nibh. Phasellus imperdiet viverra lorem, eget vehicula elit vestibulum id. Cras a magna libero. Suspendisse tincidunt vestibulum justo, sit amet imperdiet lectus venenatis a. Curabitur nisl turpis, sollicitudin iaculis blandit ut, semper non velit. Morbi congue eu ipsum eu dignissim. Aenean maximus faucibus lectus. Pellentesque tellus augue, gravida in auctor non, hendrerit sed nisi. Vivamus eu leo eu lorem consequat ornare id non odio. In hac habitasse platea dictumst. Praesent in faucibus orci. Fusce laoreet, est at interdum elementum, nisi sapien mollis nisl, vitae dictum ante velit ut augue. Quisque laoreet egestas varius. Pellentesque id euismod augue. Sed in consequat metus.Sed ullamcorper dapibus ex, nec tincidunt purus consequat rhoncus. Nunc eu diam vestibulum, convallis nisi id, bibendum mi. Maecenas feugiat tellus mi, sed rutrum libero pellentesque bibendum. Donec consectetur pellentesque est at molestie. Nulla eget massa vel sem lacinia dapibus. Ut interdum leo non ultrices elementum. Quisque et erat varius diam laoreet porta. Praesent tempus porttitor orci quis accumsan. Ut iaculis sollicitudin neque a posuere. Nam fermentum felis non neque suscipit rhoncus. Interdum et malesuada fames ac ante ipsum primis in faucibus. Mauris accumsan, odio et interdum egestas, dui eros laoreet urna, eget consectetur massa sapien id dui. Praesent et ante nec arcu dictum congue vel consectetur lacus. Integer sagittis neque non vehicula accumsan. Duis ac velit orci. Vivamus sem nunc, pharetra nec bibendum at, rutrum in ligula. Fusce varius eget risus convallis pharetra. Cras elit sem, tincidunt quis sollicitudin in, tempus ac lectus. Sed libero est, ornare sit amet orci sed, hendrerit egestas erat. Nam varius lacinia est ac consequat. Integer sollicitudin aliquam mi, sit amet finibus risus mattis sollicitudin. Integer hendrerit, massa ut tincidunt pharetra, dolor felis vulputate dui, at venenatis arcu mauris vel massa. Donec id nisi vel eros viverra commodo accumsan at risus.Fusce ut nulla quam. Praesent sodales, lectus nec viverra blandit, urna magna varius est, eu varius nibh magna eu arcu. Curabitur vitae consectetur nisl, a convallis nunc. Sed blandit est dui, ac accumsan nisl facilisis"
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "Rating: 8.0"
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
        posterImageView.anchor(top: scrollView.topAnchor, width: 200, height: 300)
        
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
    }
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        posterImageView.addGestureRecognizer(tapGesture)
        posterImageView.isUserInteractionEnabled = true
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
