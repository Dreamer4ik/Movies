//
//  SortingOptions.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 02.11.2023.
//

import Foundation

enum SortingOptions: CaseIterable {
    case popularity
    case rating
    case newier
    case older
    
    func comparator() -> (Movie, Movie) -> Bool {
        switch self {
        case .popularity:
            return { $0.popularity > $1.popularity }
        case .rating:
            return { $0.voteAverage > $1.voteAverage }
        case .newier:
            return { (m1, m2) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date1 = dateFormatter.date(from: m1.releaseDate)
                let date2 = dateFormatter.date(from: m2.releaseDate)
                return date1 ?? Date.distantPast > date2 ?? Date.distantPast
            }
        case .older:
            return { (m1, m2) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date1 = dateFormatter.date(from: m1.releaseDate)
                let date2 = dateFormatter.date(from: m2.releaseDate)
                return date1 ?? Date.distantPast < date2 ?? Date.distantPast
            }
        }
    }
}
