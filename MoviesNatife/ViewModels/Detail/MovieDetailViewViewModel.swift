//
//  MovieDetailViewViewModel.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

final class MovieDetailViewViewModel {
    private let movie: MovieDetails
//    public var episodes: [String] {
//        character.episode
//    }
    
    // MARK: - Lifecycle
    
    init(movie: MovieDetails) {
        self.movie = movie
    }
    
//    private var requestURL: URL? {
//        return URL(string: character.url)
//    }
    
    public var title: String {
        return movie.title
    }
}
