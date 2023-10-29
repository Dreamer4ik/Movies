//
//  MovieEndpoint.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation

/// Represents unique API endpoint
enum MovieEndpoint: String, CaseIterable, Hashable {
    /// Endpoint to get movie info
    case popularMovies = "/3/movie/popular"
    case genresOfMovies = "/3/genre/movie/list"
    case searchMoviesByTitle = "/3/search/movie"
    case fetchMovieById = "/3/movie"
}
