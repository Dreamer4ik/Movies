//
//  AlamofireHelper.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit
import Alamofire

let httpHeaders: HTTPHeaders =  [
    "accept": "application/json",
    "Authorization": "Bearer \(BaseConstants.API.API_KEY)"
]


enum AlamofireHelperNetworkResult<T: Codable> {
    case success(T)
    case failure(Error)
}

enum AFError: Error {
    case noInternetConnection
    case failedToCreateRequest
    case failedToGetData
    case somethingWentWrong(String)
    case failedToCache
}

typealias AlamofireResultCallback<T: Codable> = (AlamofireHelperNetworkResult<T>) -> Void

final class AlamofireHelper {
    
    class func sendRequest<T: Codable>(
        expecting type: T.Type,
        request: MovieRequest,
        method: HTTPMethod,
        params: Parameters?,
        appender: Int? = nil,
        completion: @escaping AlamofireResultCallback<T>,
        needToShowAlertOnError: Bool = true
    ) {
        guard Network.reachability?.isReachable == true else {
            APICacheManager.shared.getCachedResponse(for: request.url?.absoluteString ?? "") { (result: AlamofireHelperNetworkResult<T>) in
                switch result {
                case .success(let cachedData):
                    completion(.success(cachedData))
                case .failure:
                    completion(.failure(AFError.noInternetConnection))
                }
            }
            return
        }
        
        guard var urlRequest = request.url else {
            completion(.failure(AFError.failedToCreateRequest))
            return
        }
        
        AF.request(urlRequest, method: method, parameters: params, encoding: URLEncoding.queryString, headers: httpHeaders)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    if let value = value as? MoviesResponse {
                        APICacheManager.shared.cacheResponse(value, for: request.url?.absoluteString ?? "")
                    }
                    completion(.success(value))
                case .failure(let error):
                    guard let data = response.data,
                          let message = try? JSONDecoder().decode(String.self, from: data) else {
                        completion(.failure(error))
                        return
                    }
                    
                    if needToShowAlertOnError {
                        // Check server-side error message
                    }
                    completion(.failure(AFError.somethingWentWrong(message)))
                }
            }
    }
}

