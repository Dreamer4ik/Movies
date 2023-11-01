//
//  MovieDetailViewViewModel.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

final class MovieDetailViewViewModel {
    // MARK: - Properties
    private let movie: MovieDetails
    public let trailerURL: URL?
    
    // MARK: - Lifecycle
    init(movie: MovieDetails, trailerURL: URL?) {
        self.movie = movie
        self.trailerURL = trailerURL
    }
    
    public var title: String {
        return movie.title
    }
    
    public var trailerButtonIsHidden: Bool {
        return trailerURL == nil
    }
    
    public var imageURL: URL? {
        guard let posterPath = movie.posterPath else { return BaseConstants.API.noImageURL }
        return  URL(string: "\(BaseConstants.API.posterBaseUrl)\(posterPath)")
    }
    
    public var countryAndYear: String {
        let originCountry = movie.productionCompanies.first?.originCountry ?? "Unknown"
        return "\(originCountry), \(releaseDateText)"
    }
    
    public var releaseDateText: String {
        if let date = Utilities.dateFormatter().date(from: movie.releaseDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: date)
            return year
        } else {
            return "None"
        }
    }
    
    public var descriptionText: String {
        return movie.overview
    }
    
    public var roundedRating: String {
        let roundedRating = (movie.voteAverage * 10).rounded() / 10
        return String(format: "%.1f", roundedRating)
    }
    
    public var genres: String {
        return movie.genres.map { $0.name.localized() }.joined(separator: ", ")
    }
}
