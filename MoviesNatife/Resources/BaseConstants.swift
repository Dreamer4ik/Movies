//
//  BaseConstants.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import Foundation

struct BaseConstants {
    enum API {
        static let API_KEY = "278ac8df3908e82ee6d855b6042d1ff2"
        static let baseUrl =  "https://api.themoviedb.org"
        static let posterBaseUrl = "https://image.tmdb.org/t/p/w500/"
        static let noImageURL = URL(string: "https://archive.org/download/no-photo-available/no-photo-available.png")
    }
    
    enum Localization {
        static let popularMoviesTitle = "popularMovies".localized()
        static let searchMoviesPlaceholder = "searchByTitle".localized()
        static let rating = "rating".localized()
        static let noGenre = "noGenre".localized()
        static let dismissText = "dismiss".localized()
        
        // MARK: - SortingOptions text
        static let sortByPopularity = "sortByPopularity".localized()
        static let sortByRating = "sortByRating".localized()
        static let sortByNew = "sortByNew".localized()
        static let sortByOld = "sortByOld".localized()
        static let cancel = "cancel".localized()
    }
}

