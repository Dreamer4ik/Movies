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
    private var manager: ApiManager?
    private var movies = [Movie]()
    private var selectedSortingOption: SortingOptions = .first
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMovies()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        manager = ApiManager(viewController: self)
        view.backgroundColor = .purple
        setUpNavBar()
    }
    
    private func setUpNavBar() {
        title = "Popular Movies"
        Utilities.configureNavBar(vc: self)
        
        navigationController?.navigationBar.tintColor = .black
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let modifiedImage = UIImage(
            systemName: "list.dash")?
            .withConfiguration(symbolConfiguration)
        //            .withTintColor(.black)
        
        
        let sortButton = UIBarButtonItem(image: modifiedImage, style: .plain, target: self, action: #selector(showSortingOptions))
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func fetchMovies() {
        manager?.getPopularMovies { [weak self] result in
            switch result {
            case .success(let models):
                self?.movies = models.results
                print(models.results.count)
                print(models.results.compactMap({
                    $0.title
                }))
                
            case .failure(let error):
                print(error.debugDescription)
            }
        }
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


