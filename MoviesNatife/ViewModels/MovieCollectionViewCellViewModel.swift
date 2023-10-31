//
//  MovieCollectionViewCellViewModel.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation
import UIKit

final class MovieCollectionViewCellViewModel: Hashable, Equatable {
    // MARK: - Properties
    private let movieTitle: String
    private let releaseDate: String
    public let genreIDS: [Int]
    private let rating: Double
    private let posterPath: String?
    
    // MARK: - Init
    init(
        movieTitle: String,
        releaseDate: String,
        genreIDS: [Int],
        rating: Double,
        posterPath: String?
    ) {
        self.movieTitle = movieTitle
        self.releaseDate = releaseDate
        self.genreIDS = genreIDS
        self.rating = rating
        self.posterPath = posterPath
    }
    
    public var movieTitleText: String {
        return "\(movieTitle), \(releaseDateText)"
    }
    
    public var imageURL: URL? {
        guard let posterPath = posterPath else { return noImageURL }
        return  URL(string: "\(posterBaseUrl)\(posterPath)")
    }
    
    private var releaseDateText: String {
        if let date = Utilities.dateFormatter().date(from: releaseDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: date)
            return year
        } else {
            return "None"
        }
    }
    
    
    public var roundedRating: String {
        let roundedRating = (rating * 10).rounded() / 10
        return String(format: "%.1f", roundedRating)
    }
    
    public func fetchGenres(completion: @escaping (Result<GenresResponse, Error>) -> Void) {
        ApiManager.shared.fetchGenres { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Hashable
    static func == (lhs: MovieCollectionViewCellViewModel, rhs: MovieCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(movieTitle)
        hasher.combine(releaseDate)
        hasher.combine(genreIDS)
        hasher.combine(rating)
    }
}


