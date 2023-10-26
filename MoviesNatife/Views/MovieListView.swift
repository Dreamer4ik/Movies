//
//  MovieListView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import UIKit

protocol MovieListViewDelegate: AnyObject {
    func movieListView(
        _ movieListView: MovieListView,
        didSelectMovie movie: Movie
    )
}
/// View that handles showing list of movies, loader, etc.
final class MovieListView: UIView {
    // MARK: - Properties
    public weak var delegate: MovieListViewDelegate?
    private let viewModel = MovieListViewViewModel()
    private let searchInputView = MovieSearchInputView()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = false
        collectionView.alpha = 0
        collectionView.register(MovieCollectionViewCell.self,
                                forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.register(MovieLoadingCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: MovieLoadingCollectionReusableView.identifier)
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        viewModel.fetchMovies()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubviews(searchInputView, collectionView, spinner)
        spinner.center(inView: self)
        spinner.setDimensions(width: 100, height: 100)
        spinner.startAnimating()
        
        searchInputView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, height: 60)
        searchInputView.delegate = self
        
        collectionView.anchor(top: searchInputView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        setUpCollectionView()
        viewModel.delegate = self
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = viewModel
        collectionView.delegate = viewModel
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func handleRefresh() {
        refreshControl.beginRefreshing()
        viewModel.reloadMovies()
    }
    
    @objc private func didTapDismiss() {
        searchInputView.searchBar.resignFirstResponder()
    }
}

// MARK: - MovieListViewViewModelDelegate
extension MovieListView: MovieListViewViewModelDelegate {
    func didReloadMovies() {
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func didSelectMovie(_ movie: Movie) {
        delegate?.movieListView(self, didSelectMovie: movie)
    }
    
    func didLoadMoreMovies(with newIndexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            print("newIndexPaths: \(newIndexPaths)")
            collectionView.insertItems(at: newIndexPaths)
        }
    }
    
    func didLoadInitialMovies() {
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear) {
            self.collectionView.alpha = 1
        }
        animator.startAnimation()
    }
}

// MARK: - MovieSearchInputViewDelegate
extension MovieListView: MovieSearchInputViewDelegate {
    func searchInputView(_ inputView: MovieSearchInputView, didChangeSearchText text: String) {
        print(text)
    }
    
    func searchInputViewDidTapSearchKeyboardButton(_ inputView: MovieSearchInputView) {
        
    }
}
