//
//  PopularMoviesViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

class PopularMoviesViewController: UIViewController {
    // MARK: - Properties
    private let movieListView = MovieListView()
    private var selectedSortingOption: SortingOptions = .popularity
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .systemBackground
        setUpNavBar()
        
        movieListView.delegate = self
        movieListView.errorDelegate = self
        view.addSubview(movieListView)
        movieListView.addConstraintsToFillView(view)
        
        view.addSubview(spinner)
        spinner.center(inView: view)
        spinner.setDimensions(width: 100, height: 100)
    }
    
    private func setUpNavBar() {
        title = BaseConstants.Localization.popularMoviesTitle
        Utilities.configureNavBar(vc: self)
        
        navigationController?.navigationBar.tintColor = .label
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let modifiedImage = UIImage(
            systemName: "list.dash")?
            .withConfiguration(symbolConfiguration)
        
        
        let sortButton = UIBarButtonItem(image: modifiedImage, style: .plain, target: self, action: #selector(showSortingOptions))
        navigationItem.rightBarButtonItem = sortButton
    }
    
    func openSortingOptions() {
        let action = UIAlertController.actionSheetWithItems(items: [
            (BaseConstants.Localization.sortByPopularity, SortingOptions.popularity),
            (BaseConstants.Localization.sortByRating, SortingOptions.rating),
            (BaseConstants.Localization.sortByNew, SortingOptions.newier),
            (BaseConstants.Localization.sortByOld, SortingOptions.older)
            
        ], currentSelection: selectedSortingOption, action: { [weak self] (value) in
            if let sortingOption = value as? SortingOptions {
                self?.selectedSortingOption = sortingOption
                self?.movieListView.didChangeSortingOption(sortingOption)
            }
        })
        
        action.addAction(UIAlertAction(title: BaseConstants.Localization.cancel, style: .cancel, handler: nil))
        self.present(action, animated: true, completion: nil)
    }
    // MARK: - Actions
    @objc private func showSortingOptions() {
        openSortingOptions()
    }
    
    
}

// MARK: - MovieListViewDelegate
extension PopularMoviesViewController: MovieListViewDelegate {
    func didChangeSortingOption(_ sortingOption: SortingOptions) {
        print(sortingOption)
    }
    
    func movieListView(_ movieListView: MovieListView, didSelectMovie movie: Movie) {
        spinner.startAnimating()
        if Network.reachability?.isReachable == false {
            Alert.showNotice(viewController: self,
                             title: BaseConstants.Localization.error,
                             message: BaseConstants.Localization.offline)
            spinner.stopAnimating()
        } else {
            let dispatchGroup = DispatchGroup()
            var trailerURL: URL?
            
            dispatchGroup.enter()
            ApiManager.shared.fetchMovieVideosById(id: movie.id) { [weak self] result in
                defer { dispatchGroup.leave() }
                
                switch result {
                case .success(let videoResponse):
                    if let trailerVideo = videoResponse.results.first(where: { $0.type == TypeEnum.trailer }) {
                        let trailerKey = trailerVideo.key
                        trailerURL = URL(string: "https://www.youtube.com/watch?v=\(trailerKey)")
                    }
                case .failure(let error):
                    print("Error fetching movie videos: \(error)")
                    self?.spinner.stopAnimating()
                    guard let vc = self else { return }
                    Alert.showNotice(viewController: vc,
                                     title: BaseConstants.Localization.error,
                                     message: error.localizedDescription)
                }
            }
            
            var movieDetails: MovieDetails?
            
            dispatchGroup.enter()
            ApiManager.shared.fetchMovieDetailsById(id: movie.id) { [weak self] result in
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let movie):
                    movieDetails = movie
                case .failure(let error):
                    self?.spinner.stopAnimating()
                    print(error.localizedDescription)
                    guard let vc = self else { return }
                    Alert.showNotice(viewController: vc,
                                     title: BaseConstants.Localization.error,
                                     message: error.localizedDescription)
                    
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.spinner.stopAnimating()
                guard let movieDetails = movieDetails else { return }
                let vm = MovieDetailViewViewModel(movie: movieDetails, trailerURL: trailerURL)
                let vc = MovieDetailsViewController(viewModel: vm)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

// MARK: - MovieListViewDelegate
extension PopularMoviesViewController: MovieListViewErrorDelegate {
    func didEncounterError(_ error: Error) {
        Alert.showNotice(viewController: self,
                         title: BaseConstants.Localization.error,
                         message: error.localizedDescription)
    }
}
