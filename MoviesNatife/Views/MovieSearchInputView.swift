//
//  MovieSearchInputView.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 26.10.2023.
//

import UIKit

protocol MovieSearchInputViewDelegate: AnyObject {
    func searchInputView(_ inputView: MovieSearchInputView,
                           didChangeSearchText text: String)
    func searchInputViewDidTapSearchKeyboardButton(_ inputView: MovieSearchInputView)
}

/// View for top part of search screen with search bar
final class MovieSearchInputView: UIView {
    // MARK: - Properties
    weak var delegate: MovieSearchInputViewDelegate?
    
    public let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        addSubviews(searchBar)
        backgroundColor = .systemBackground
        searchBar.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 58)
        searchBar.delegate = self
        
        let doneToolbar = createDoneToolbar()
        searchBar.inputAccessoryView = doneToolbar
    }
    
    // MARK: - Private
    private func createDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc private func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Public
}

// MARK: - UISearchBarDelegate
extension MovieSearchInputView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Notify delegate of change text
        delegate?.searchInputView(self, didChangeSearchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Notify that search button was tapped
        searchBar.resignFirstResponder()
        delegate?.searchInputViewDidTapSearchKeyboardButton(self)
    }
}

