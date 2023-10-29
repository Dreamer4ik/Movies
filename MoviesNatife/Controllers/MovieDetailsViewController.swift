//
//  MovieDetailsViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .purple
        Utilities.configureNavBar(vc: self)
    }
    
    // MARK: - Actions
}
