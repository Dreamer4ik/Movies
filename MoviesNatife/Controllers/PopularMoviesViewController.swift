//
//  PopularMoviesViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

enum SortingOptions {
    case first
    case second
    case third
    case forth
}


class PopularMoviesViewController: UIViewController {
    // MARK: - Properties
//    private var manager: ApiManager?
    private let movieListView = MovieListView()
    private var selectedSortingOption: SortingOptions = .first
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
//        manager = ApiManager(viewController: self) // fix me this alert
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
    
    // MARK: - Actions
    @objc private func showSortingOptions() {
        openSortingOptions()
    }
    
    func openSortingOptions() {
        let action = UIAlertController.actionSheetWithItems(items: [
            ("Option 1 Title", SortingOptions.first),
            ("Option 2 Title", SortingOptions.second),
            ("Option 3 Title", SortingOptions.third),
            ("Option 4 Title", SortingOptions.forth)
            
        ], currentSelection: selectedSortingOption, action: { (value) in
            if let sortingOption = value as? SortingOptions {
                self.selectedSortingOption = sortingOption
                //TODO: Update UI or perform any other necessary actions here
            }
        })
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(action, animated: true, completion: nil)
    }
}

// MARK: - MovieListViewDelegate
extension PopularMoviesViewController: MovieListViewDelegate {
    func movieListView(_ movieListView: MovieListView, didSelectMovie movie: Movie) {
        // TODO: кидать загрузку через movie.id ???
        print(movie)
    }
}