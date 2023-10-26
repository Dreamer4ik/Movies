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
    public let rating: Double
    public let movieImageUrl: URL? // fixme make private
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()
    
    // MARK: - Init
    
    init(
        movieTitle: String,
        releaseDate: String,
        genreIDS: [Int],
        rating: Double,
        movieImageUrl: URL?
    ) {
        self.movieTitle = movieTitle
        self.releaseDate = releaseDate
        self.genreIDS = genreIDS
        self.rating = rating
        self.movieImageUrl = movieImageUrl
    }
    
    public var movieTitleText: String {
        return "\(movieTitle), \(releaseDateText)"
    }
    
    private var releaseDateText: String {
        if let date = dateFormatter.date(from: releaseDate) {
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            let year = yearFormatter.string(from: date)
            return year
        } else {
            return "None"
        }
    }
    
    public func fetchImage(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = movieImageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        AlamofireImageLoader.shared.loadImage(from: url) { result in
            completion(result)
        }
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
        hasher.combine(movieImageUrl)
    }
}


