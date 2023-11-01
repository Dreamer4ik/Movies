//
//  MovieRequest.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation

/// Object that represents a single API call
final class MovieRequest {
    
    /// Desired endpoint
    let endpoint: MovieEndpoint
    /// Path components for API, if any
    private let pathComponents: [String]
    /// Query arguments for API, if any
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    private var urlString: String {
        var string = BaseConstants.API.baseUrl
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach {
                string += "/\($0)"
            }
        }
        
        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else {
                    return nil
                }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Desired httpMethod
    public let httpMethod = "GET"
    
    // MARK: - Public
    /// Construct request
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of Path components
    ///   - queryParameters: Collection of query parameters
    public init(
        endpoint: MovieEndpoint,
        pathComponents: [String] = [],
        queryParameters: [URLQueryItem] = []
    ) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    /// Attempt to create request
    /// - Parameter url: URL to parse
    convenience init?(url: URL) {
        let string = url.absoluteString
        
        if !string.contains(BaseConstants.API.baseUrl) {
            return nil
        }
        
        let trimmed = string.replacingOccurrences(of: BaseConstants.API.baseUrl, with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let endpointString = components[0] // Endpoint
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let movieEndpoint = MovieEndpoint(rawValue: endpointString) {
                    self.init(endpoint: movieEndpoint,
                              pathComponents: pathComponents)
                    return
                }
            }
        } else if trimmed.contains("?"){
            let components = trimmed.components(separatedBy: "?")
            if !components.isEmpty {
                let endpointString = components[0]
                let queryItemsString = components[1]
                // value=name&value=name
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")
                    return URLQueryItem(name: parts[0], value: parts[1])
                })
                if let movieEndpoint = MovieEndpoint(rawValue: endpointString) {
                    self.init(endpoint: movieEndpoint, queryParameters: queryItems)
                    return
                }
            }
        }
        
        return nil
    }
}

extension MovieRequest {
    static let listPopularMoviesRequest = MovieRequest(endpoint: .popularMovies)
    static let listOfMoviesGenres = MovieRequest(endpoint: .genresOfMovies)
    static let searchForMovies = MovieRequest(endpoint: .searchMoviesByTitle)
//    static let fetchMovieById = MovieRequest(endpoint: .fetchMovieById)
    static func fetchMovieByIdRequest(movieID: Int) -> MovieRequest {
        return MovieRequest(endpoint: .fetchMovieById, pathComponents: [String(movieID)])
    }
}

