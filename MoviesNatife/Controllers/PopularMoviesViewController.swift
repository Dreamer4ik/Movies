//
//  PopularMoviesViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

enum SortingOptions: CaseIterable {
    case first
    case second
    case third
    case forth
}

class PopularMoviesViewController: UIViewController {
    // MARK: - Properties
    private let movieListView = MovieListView()
    private var selectedSortingOption: SortingOptions = .first
    
    
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
        view.addSubview(movieListView)
        movieListView.addConstraintsToFillView(view)
    }
    
    private func setUpNavBar() {
        title = "Popular Movies"
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
            ("Sort by 1", SortingOptions.first),
            ("Sort by 2", SortingOptions.second),
            ("Sort by 3", SortingOptions.third),
            ("Sort by 4", SortingOptions.forth)
            
        ], currentSelection: selectedSortingOption, action: { (value) in
            if let sortingOption = value as? SortingOptions {
                self.selectedSortingOption = sortingOption
                self.movieListView.didChangeSortingOption(sortingOption)
            }
        })
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
        let dispatchGroup = DispatchGroup()
        var trailerURL: URL?
        
        dispatchGroup.enter()
        ApiManager.shared.fetchMovieVideosById(id: movie.id) { result in
            defer { dispatchGroup.leave() }
            
            switch result {
            case .success(let videoResponse):
                if let trailerVideo = videoResponse.results.first(where: { $0.type == TypeEnum.trailer }) {
                    let trailerKey = trailerVideo.key
                    trailerURL = URL(string: "https://www.youtube.com/watch?v=\(trailerKey)")
                }
            case .failure(let error):
                print("Error fetching movie videos: \(error)")
            }
        }
        
        var movieDetails: MovieDetails?
        
        dispatchGroup.enter()
        ApiManager.shared.fetchMovieDetailsById(id: movie.id) { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .success(let movie):
                movieDetails = movie
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            guard let movieDetails = movieDetails else { return }
                let vm = MovieDetailViewViewModel(movie: movieDetails, trailerURL: trailerURL)
                let vc = MovieDetailsViewController(viewModel: vm)
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
