//
//  ApiManager.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import Foundation
import Alamofire

enum ApiManagerNetworkResult<T> {
    case success(T)
    case failure(Error)
}

enum ApiManagerError: Error {
    case failedToCreateRequest(message: String)
    case failedToGetData(message: String)
}

typealias ApiManagerCallback<T> = (ApiManagerNetworkResult<T>) -> Void

class ApiManager: NSObject {
    static let shared = ApiManager() // fixMe
    let params: Parameters = ["api_key": API_KEY]
    
//    let viewController: UIViewController
//    
//    init(viewController: UIViewController) {
//        self.viewController = viewController
//        super.init()
//    }
    
    func getPopularMovies(page: Int? = nil, completionHandler: @escaping ApiManagerCallback<MoviesResponse>) {
        var updatedParams = params
        if let page = page {
            updatedParams["page"] = "\(page)"
        }
        
        AlamofireHelper.sendRequest(expecting: MoviesResponse.self, request: .listPopularMoviesRequest, method: .get, params: updatedParams) { (result: AlamofireHelperNetworkResult<MoviesResponse>) in
            switch result {
            case .success(let movies):
                completionHandler(.success(movies))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchGenres(completionHandler: @escaping ApiManagerCallback<GenresResponse>) {
        AlamofireHelper.sendRequest(expecting: GenresResponse.self, request: .listOfMoviesGenres, method: .get, params: params) { (result: AlamofireHelperNetworkResult<GenresResponse>) in
            switch result {
            case .success(let genres):
                completionHandler(.success(genres))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchMoviesByTitle(page: Int? = nil, request: MovieRequest, completionHandler: @escaping ApiManagerCallback<MoviesResponse>) {
        var updatedParams = params
        if let page = page {
            updatedParams["page"] = "\(page)"
        }
        AlamofireHelper.sendRequest(expecting: MoviesResponse.self, request: request, method: .get, params: updatedParams) { (result: AlamofireHelperNetworkResult<MoviesResponse>) in
            switch result {
            case .success(let movies):
                completionHandler(.success(movies))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchMovieDetailsById(id: Int, completionHandler: @escaping ApiManagerCallback<MovieDetails>) {
        let request = MovieRequest.fetchMovieByIdRequest(movieID: id)
        AlamofireHelper.sendRequest(expecting: MovieDetails.self, request: request, method: .get, params: params) { (result: AlamofireHelperNetworkResult<MovieDetails>) in
            switch result {
            case .success(let movie):
                completionHandler(.success(movie))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func fetchMovieVideosById(id: Int, completionHandler: @escaping ApiManagerCallback<VideoResponse>) {
        let request = MovieRequest(endpoint: .fetchMovieById, pathComponents: [String(id), "videos"])
        AlamofireHelper.sendRequest(expecting: VideoResponse.self, request: request, method: .get, params: params) { (result: AlamofireHelperNetworkResult<VideoResponse>) in
            switch result {
            case .success(let videos):
                completionHandler(.success(videos))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}
