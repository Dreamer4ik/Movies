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
    case failure(String)
}

typealias ApiManagerCallback<T> = (ApiManagerNetworkResult<T>) -> Void

class ApiManager: NSObject {
    let params: Parameters = ["api_key": API_KEY]
    let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func getPopularMovies(completionHandler: @escaping ApiManagerCallback<MoviesResponse>) {
        AlamofireHelper.sendRequest(expecting: MoviesResponse.self, endpoint: popular, from: viewController, method: .get, params: params, completionHandler: { (result: AlamofireHelperNetworkResult<MoviesResponse>) in
            switch result {
            case .success(let movies):
                completionHandler(.success(movies))
            case .failure(let message):
                completionHandler(.failure(message))
            }
        })
    }
}
