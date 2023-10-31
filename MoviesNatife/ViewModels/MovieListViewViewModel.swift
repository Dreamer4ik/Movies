//
//  MovieListViewViewModel.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import UIKit

enum ViewMode {
    case regular
    case search
}

protocol MovieListViewViewModelDelegate: AnyObject {
    func didLoadInitialMovies()
    func didReloadMovies()
    func didLoadMoreMovies()
    func didSelectMovie(_ movie: Movie)
    func didChangeSortingOption(_ sortingOption: SortingOptions)
}

/// View model to handle movie list view logic
final class MovieListViewViewModel: NSObject {
    // MARK: - Properties
    weak var delegate: MovieListViewViewModelDelegate?
    var viewMode: ViewMode = .regular
    private var searchText = ""
    private var currentRequest: MovieRequest?
    private var isLoadingMovies = false
    
    private var searchResultHandler: (() -> Void)?
    private var noResultsHandler: (() -> Void)?
    
    private var movies: [Movie] = [] {
        didSet {
            for movie in movies {
                let viewModel = MovieCollectionViewCellViewModel(
                    movieTitle: movie.title,
                    releaseDate: movie.releaseDate,
                    genreIDS: movie.genreIDS,
                    rating: movie.voteAverage,
                    posterPath: movie.posterPath
                )
                
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [MovieCollectionViewCellViewModel] = []
    private var resultPages: (currentPage: Int, totalPages: Int) = (0, 0)
    
    // MARK: - API
    
    /// Fetch initial set of movies (20)
    public func fetchMovies(reload: Bool? = nil) {
        guard !isLoadingMovies else {
            return
        }
        
        isLoadingMovies = true
        
        // Cache doesn't work
        switch viewMode {
        case .regular:
            ApiManager.shared.getPopularMovies { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let models):
                    strongSelf.resultPages = (models.page, models.totalPages)
                    strongSelf.movies = models.results
                    
                    DispatchQueue.main.async {
                        if let reload = reload {
                            strongSelf.delegate?.didReloadMovies()
                        } else {
                            strongSelf.delegate?.didLoadInitialMovies()
                        }
                        strongSelf.isLoadingMovies = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    strongSelf.isLoadingMovies = false
                }
            }
        case .search:
            executeSearch()
        }
    }
    
    /// Paginate if additional movies are needed
    public func fetchAdditionalMovies() {
        guard !isLoadingMovies else {
            return
        }
        
        isLoadingMovies = true
        print("Fetching more movies")
        resultPages.currentPage += 1
        
        switch viewMode {
        case .regular:
            ApiManager.shared.getPopularMovies(page: resultPages.currentPage) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let moviesResponse):
                    let moreMovies = moviesResponse.results
                    strongSelf.movies.append(contentsOf: moreMovies)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didLoadMoreMovies()
                        strongSelf.isLoadingMovies = false
                    }
                case .failure(let failure):
                    print(failure.localizedDescription)
                    strongSelf.isLoadingMovies = false
                }
            }
        case .search:
            guard let currentRequest = currentRequest else { return }
            ApiManager.shared.fetchMoviesByTitle(page: resultPages.currentPage, request: currentRequest) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let moviesResponse):
                    let moreMovies = moviesResponse.results
                    strongSelf.movies.append(contentsOf: moreMovies)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didLoadMoreMovies()
                        strongSelf.isLoadingMovies = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    public func reloadMovies() {
        switch viewMode {
        case .regular:
            movies.removeAll()
            cellViewModels.removeAll()
            fetchMovies(reload: true)
        case .search:
            movies.removeAll()
            cellViewModels.removeAll()
            DispatchQueue.main.async {
                self.delegate?.didReloadMovies()
            }
        }
    }
    
    
    // MARK: - Search
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: MovieRequest) {
        ApiManager.shared.fetchMoviesByTitle(request: request) { [weak self] result in
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
            case .failure(let failure):
                self?.handleNoResults()
            }
        }
    }
    
    public func executeSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        // Build arguments
        var queryParams: [URLQueryItem] = [
            URLQueryItem(name: "query", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        ]
        
        // Create request
        let request = MovieRequest(
            endpoint: .searchMoviesByTitle,
            queryParameters: queryParams
        )
        
        // Notify view of results, no results, error
        currentRequest = request
        makeSearchAPICall(MoviesResponse.self, request: request)
    }
    
    private func processSearchResults(model: Codable) {
        if let movieResults = model as? MoviesResponse, !movieResults.results.isEmpty {
            reloadMovies()
            movies = movieResults.results
            resultPages = (movieResults.page, movieResults.totalPages)
            self.handleResults()
        } else {
            self.handleNoResults()
        }
    }
    
    public func set(query text: String) {
        self.searchText = text
    }
    
    // MARK: - Handlers
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
    }
    
    public func registerSearchResultHandler(_ block: @escaping () -> Void) {
        self.searchResultHandler = block
    }
    
    private func handleNoResults() {
        noResultsHandler?()
    }
    
    private func handleResults() {
        searchResultHandler?()
    }
    
    func updateSortingOption(_ sortingOption: SortingOptions) {
        // TODO: - Сделать сортировки
//        self.selectedSortingOption = sortingOption
        switch sortingOption {
        case .first:
            print("1")
        case .second:
            print("2")
        case .third:
            print("3")
        case .forth:
            print("4")
        }
    }
    
    // MARK: - Helpers
    public var shouldShowLoadMoreIndicator: Bool {
        return resultPages.0 < resultPages.1 && resultPages.0 > 0
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MovieListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieCollectionViewCell else {
            preconditionFailure("MovieCollectionViewCell error")
        }
        let viewModel = cellViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let movie = movies[indexPath.row]
        delegate?.didSelectMovie(movie)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter ,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: MovieLoadingCollectionReusableView.identifier,
                for: indexPath
              ) as? MovieLoadingCollectionReusableView else {
            preconditionFailure("MovieLoadingCollectionReusableView error")
        }
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        return CGSize(width: collectionView.width, height: 100)
    }
}

// MARK: - UICollectionViewFlowLayout
extension MovieListViewViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = collectionView.bounds
        let width: CGFloat
        width = (bounds.width - 30)
        return CGSize(width: width, height: width * 1.3)
    }
}

// MARK: - UIScrollViewDelegate
extension MovieListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMovies,
              !cellViewModels.isEmpty else {
            return
        }
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom < height {
            fetchAdditionalMovies()
        }
    }
}
