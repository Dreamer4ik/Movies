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
}
