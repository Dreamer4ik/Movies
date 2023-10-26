//
//  MovieListViewViewModel.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import UIKit

protocol MovieListViewViewModelDelegate: AnyObject {
    func didLoadInitialMovies()
    func didReloadMovies()
    func didLoadMoreMovies(with newIndexPaths: [IndexPath])
    func didSelectMovie(_ movie: Movie)
}

/// View model to handle movie list view logic
final class MovieListViewViewModel: NSObject {
    
    weak var delegate: MovieListViewViewModelDelegate?
//    private var manager: ApiManager?
    
    private var isLoadingMovies = false
    
    
    private var movies: [Movie] = [] {
        didSet {
            for movie in movies {
                let viewModel = MovieCollectionViewCellViewModel(
                    movieTitle: movie.title,
                    releaseDate: movie.releaseDate,
                    genreIDS: movie.genreIDS,
                    rating: movie.voteAverage,
                    movieImageUrl: URL(string: "\(posterBaseUrl)\(movie.posterPath)")
                )
                
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels: [MovieCollectionViewCellViewModel] = []
    private var resultPages: (currentPage: Int, totalPages: Int) = (0, 0)
    
    /// Fetch initial set of movies (20)
    public func fetchMovies(reload: Bool? = nil) {
        // Cache work
//        AlamofireHelper.shared.execute(
//            .listPopularMoviesRequest,
//            expecting: MoviesResponse.self) { [weak self] result in
//            switch result {
//            case .success(let responseModel):
//                let results = responseModel.results
////                let info = responseModel.info
////                self?.apiInfo = info
//                self?.movies = results
//                DispatchQueue.main.async {
//                    self?.delegate?.didLoadInitialMovies()
//                }
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
        
        guard !isLoadingMovies else {
            return
        }
        
        isLoadingMovies = true
        
        // Cache doesn't work
        ApiManager.shared.getPopularMovies { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let models):
                strongSelf.resultPages = (models.page, models.totalPages)
                strongSelf.movies = models.results
                print(strongSelf.movies.count)
                print(strongSelf.cellViewModels.count)
                if let reload = reload {
                    DispatchQueue.main.async {
                        strongSelf.delegate?.didReloadMovies()
                        strongSelf.isLoadingMovies = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadInitialMovies()
                    strongSelf.isLoadingMovies = false
                }
            case .failure(let error):
                print(error.localizedDescription)
                strongSelf.isLoadingMovies = false
            }
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
        
        ApiManager.shared.getPopularMovies(page: resultPages.currentPage) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let moviesResponse):
                let moreMovies = moviesResponse.results
                let originalCount = strongSelf.movies.count
                let newCount = moreMovies.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                
                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap {
                    return IndexPath(row: $0, section: 0)
                }
                strongSelf.movies.append(contentsOf: moreMovies)
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreMovies(with: indexPathsToAdd)
                    strongSelf.isLoadingMovies = false
                }
                // DEBUG
                print("DEBUG --------------------------")
                print("Page: \(self?.resultPages.currentPage)")
                print("moviesResponse: \(moviesResponse.results)")
                print("originalCount: \(originalCount)")
                print("newCount: \(newCount)")
                print("total: \(total)")
                print("startingIndex: \(startingIndex)")
                print("indexPathsToAdd: \(indexPathsToAdd)")
                print("DEBUG --------------------------")
            case .failure(let failure):
                print(failure.localizedDescription)
                strongSelf.isLoadingMovies = false
            }
        }
    }
    
    public func reloadMovies() {
        movies.removeAll()
        cellViewModels.removeAll()
        fetchMovies(reload: true)
    }

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
        return CGSize(width: width, height: width * 0.6)
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
