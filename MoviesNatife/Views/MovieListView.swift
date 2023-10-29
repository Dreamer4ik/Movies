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
    
    func didChangeSortingOption(_ sortingOption: SortingOptions)
}
/// View that handles showing list of movies, loader, etc.
final class MovieListView: UIView {
    // MARK: - Properties
    weak var delegate: MovieListViewDelegate?
    private let viewModel = MovieListViewViewModel()
    private let searchInputView = MovieSearchInputView()
    private let noResultsView = MovieNoSearchResultsView()
    
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
        setUpHandlers(viewModel: viewModel)
        viewModel.fetchMovies()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubviews(searchInputView, collectionView, noResultsView, spinner)
        spinner.center(inView: self)
        spinner.setDimensions(width: 100, height: 100)
        spinner.startAnimating()
        
        searchInputView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, height: 60)
        searchInputView.delegate = self
        
        collectionView.anchor(top: searchInputView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
        noResultsView.center(inView: self)
        noResultsView.setDimensions(width: 200, height: 240)
        noResultsView.delegate = self
        
        setUpCollectionView()
        viewModel.delegate = self
    }
    
    private func setUpCollectionView() {
        collectionView.dataSource = viewModel
        collectionView.delegate = viewModel
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    private func setUpHandlers(viewModel: MovieListViewViewModel) {
        viewModel.registerSearchResultHandler { [weak self]  in
            DispatchQueue.main.async {
                self?.collectionView.isHidden = false
                self?.noResultsView.isHidden = true
                let animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear) {
                    self?.collectionView.alpha = 1
                }
                animator.startAnimation()
            }
        }
        
        viewModel.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultsView.isHidden = false
                self?.collectionView.isHidden = true
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleRefresh() {
        refreshControl.beginRefreshing()
        viewModel.viewMode = .regular
        viewModel.reloadMovies()
    }
    
    @objc private func didTapDismiss() {
        searchInputView.searchBar.resignFirstResponder()
    }
}

// MARK: - MovieListViewViewModelDelegate
extension MovieListView: MovieListViewViewModelDelegate {
    func didChangeSortingOption(_ sortingOption: SortingOptions) {
        viewModel.updateSortingOption(sortingOption)
    }
    
    func didReloadMovies() {
        collectionView.reloadData()
        refreshControl.endRefreshing()
        spinner.stopAnimating()
    }
    
    func didSelectMovie(_ movie: Movie) {
        delegate?.movieListView(self, didSelectMovie: movie)
    }
    
    func didLoadMoreMovies() {
        collectionView.reloadData()
    }
    
    func didLoadInitialMovies() {
        spinner.stopAnimating()
        collectionView.reloadData()
        collectionView.isHidden = false
       
        
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
        viewModel.set(query: text)
    }
    
    func searchInputViewDidTapSearchKeyboardButton(_ inputView: MovieSearchInputView) {
        viewModel.viewMode = .search
        viewModel.executeSearch()
    }
}

extension MovieListView: MovieNoSearchResultsViewDelegate {
    func didTapReturnButton() {
        viewModel.viewMode = .regular
        viewModel.reloadMovies()
        collectionView.isHidden = false
        noResultsView.isHidden = true
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear) {
            self.collectionView.alpha = 1
        }
        animator.startAnimation()
    }
}
