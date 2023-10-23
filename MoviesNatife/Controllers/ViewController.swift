//
//  ViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .purple
        setUpNavBar()
    }
    
    private func setUpNavBar() {
        title = "Popular Movies"
        Utilities.configureNavBar(vc: self)
    }
    
    // MARK: - Actions
}

