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

protocol MovieListViewViewModelErrorDelegate: AnyObject {
    func didEncounterError(_ error: Error)
}

protocol MovieListViewViewModelDelegate: AnyObject {
    func didLoadInitialMovies()
    func didReloadMovies()
    func didLoadMoreMovies()
    func didSelectMovie(_ movie: Movie)
    func didChangeSortingOption(_ sortingOption: SortingOptions)
    func shouldShowScrollToTopButton(_ show: Bool)
    func upToCollection()
}

/// View model to handle movie list view logic
final class MovieListViewViewModel: NSObject {
    // MARK: - Properties
    weak var delegate: MovieListViewViewModelDelegate?
    weak var errorDelegate: MovieListViewViewModelErrorDelegate?
    var viewMode: ViewMode = .regular
    private var searchText = ""
    private var currentRequest: MovieRequest?
    private var isLoadingMovies = false
    private var selectedSortingOption: SortingOptions = .popularity
    
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
    
    private var filteredMovies: [Movie] = []
    private let dateFormatter = Utilities.dateFormatter()
    
    private var cellViewModels: [MovieCollectionViewCellViewModel] = []
    private var resultPages: (currentPage: Int, totalPages: Int) = (0, 0)
    
    // MARK: - API
    
    /// Fetch initial set of movies (20)
    public func fetchMovies(reload: Bool? = nil) {
        guard !isLoadingMovies else {
            return
        }
        
        isLoadingMovies = true
        
        switch viewMode {
        case .regular:
            let sortingOption = "popularity.desc"
            ApiManager.shared.getPopularMovies(sortingOption: sortingOption) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let models):
                    strongSelf.resultPages = (models.page, models.totalPages)
                    var results = models.results
                    results.sort(by: strongSelf.selectedSortingOption.comparator())
                    strongSelf.movies = results
                    
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
                    strongSelf.errorDelegate?.didEncounterError(error)
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
        
        var sortingOption: String?
        
        switch selectedSortingOption {
        case .popularity:
            sortingOption = "popularity.desc"
        case .rating:
            sortingOption = "vote_average.desc"
        case .newier:
            sortingOption = "release_date.desc"
        case .older:
            sortingOption = "release_date.asc"
        }
        
        switch viewMode {
        case .regular:
            ApiManager.shared.getPopularMovies(page: resultPages.currentPage, sortingOption: sortingOption) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let moviesResponse):
                    var moreMovies = moviesResponse.results
                    moreMovies.sort(by: strongSelf.selectedSortingOption.comparator())
                    
                    strongSelf.movies.append(contentsOf: moreMovies)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didLoadMoreMovies()
                        strongSelf.isLoadingMovies = false
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    strongSelf.errorDelegate?.didEncounterError(error)
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
                    var moreMovies = moviesResponse.results
                    moreMovies.sort(by: strongSelf.selectedSortingOption.comparator())
                    
                    strongSelf.movies.append(contentsOf: moreMovies)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didLoadMoreMovies()
                        strongSelf.isLoadingMovies = false
                    }
                case .failure(let error):
                    strongSelf.errorDelegate?.didEncounterError(error)
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
    
    public func showCachMovies() {
        updateCellViewModels(with: movies)
        DispatchQueue.main.async {
            self.delegate?.didReloadMovies()
        }
    }
    
    
    // MARK: - Search
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: MovieRequest) {
        ApiManager.shared.fetchMoviesByTitle(request: request) { [weak self] result in
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
            case .failure(let error):
                self?.handleNoResults()
                self?.errorDelegate?.didEncounterError(error)
            }
        }
    }
    
    public func executeSearch() {
        if Network.reachability?.isReachable == false {
            performLocalSearch()
        } else {
            performAPISearch()
        }
        
        
    }
    
    private func performLocalSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        cellViewModels.removeAll()
        
        filteredMovies = movies.filter { movie in
            return movie.title.localizedCaseInsensitiveContains(searchText)
        }
        
        filteredMovies.sort(by: selectedSortingOption.comparator())
        
        cellViewModels = filteredMovies.map { movie in
            return MovieCollectionViewCellViewModel(
                movieTitle: movie.title,
                releaseDate: movie.releaseDate,
                genreIDS: movie.genreIDS,
                rating: movie.voteAverage,
                posterPath: movie.posterPath
            )
        }
        
        if !filteredMovies.isEmpty {
            handleResults()
            DispatchQueue.main.async {
                self.delegate?.didReloadMovies()
                self.delegate?.upToCollection()
            }
        } else {
            handleNoResults()
        }
    }
    
    private func performAPISearch() {
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
            resultPages = (movieResults.page, movieResults.totalPages)
            var results = movieResults.results
            results.sort(by: selectedSortingOption.comparator())
            movies = results
            
            self.handleResults()
            DispatchQueue.main.async {
                self.delegate?.upToCollection()
            }
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
        guard selectedSortingOption != sortingOption else { return }
        
        cellViewModels.removeAll()
        selectedSortingOption = sortingOption
        
        sortMovies(using: sortingOption.comparator())
    }
    
    
    private func sortMovies(using comparator: (Movie, Movie) -> Bool) {
        if Network.reachability?.isReachable == false {
            switch viewMode {
            case .regular:
                movies.sort(by: comparator)
                showCachMovies()
                
            case .search:
                filteredMovies.sort(by: comparator)
                updateCellViewModels(with: filteredMovies)
            }
        } else {
            movies.sort(by: comparator)
        }
        
        delegate?.didChangeSortingOption(selectedSortingOption)
    }
    
    // MARK: - Helpers
    public var shouldShowLoadMoreIndicator: Bool {
        guard Network.reachability?.isReachable == true else { return false}
        return resultPages.0 < resultPages.1 && resultPages.0 > 0
    }
    
    private func updateCellViewModels(with movies: [Movie]) {
        cellViewModels.removeAll()
        var results = movies
        results.sort(by: selectedSortingOption.comparator())
        for movie in results {
            let viewModel = MovieCollectionViewCellViewModel(
                movieTitle: movie.title,
                releaseDate: movie.releaseDate,
                genreIDS: movie.genreIDS,
                rating: movie.voteAverage,
                posterPath: movie.posterPath
            )
            
            if !cellViewModels.contains(where: { $0.movieTitle == viewModel.movieTitle }) {
                cellViewModels.append(viewModel)
            }
        }
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
        if Network.reachability?.isReachable == false && viewMode == .search {
            return .zero
        }
        
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
        let contentYoffset = scrollView.contentOffset.y
        let scrollHeight = scrollView.frame.height
        
        if contentYoffset >= abs(scrollHeight * 3) {
            delegate?.shouldShowScrollToTopButton(true)
        } else {
            delegate?.shouldShowScrollToTopButton(false)
        }
        
        guard shouldShowLoadMoreIndicator,
              !isLoadingMovies,
              !cellViewModels.isEmpty else {
            return
        }
        
        let height = scrollView.frame.size.height
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom < height {
            fetchAdditionalMovies()
        }
    }
}
