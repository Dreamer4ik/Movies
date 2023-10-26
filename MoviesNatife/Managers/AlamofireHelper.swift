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
    "Authorization": "Bearer \(API_KEY)"
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
    private let cacheManager = APICacheManager()
    static let shared = AlamofireHelper() // delete url session
    
    class func sendRequest<T: Codable>(
          expecting type: T.Type,
          request: MovieRequest,
          method: HTTPMethod,
          params: Parameters?,
          completion: @escaping AlamofireResultCallback<T>,
          needToShowAlertOnError: Bool = true
      ) {
          // Check if the response is cached
          // FixME
//          if let cachedData = APICacheManager.shared.cachedResponse(for: request.endpoint, url: request.urlAndToken) {
//              do {
//                  let result = try JSONDecoder().decode(type, from: cachedData)
//                  completion(.success(result))
//              } catch {
//                  completion(.failure(AFError.failedToCache))
//              }
//              return
//          }
          
          guard Network.reachability?.isReachable == true else {
              completion(.failure(AFError.noInternetConnection))
              return
          }
          
          guard let urlRequest = request.urlAF else {
              completion(.failure(AFError.failedToCreateRequest))
              return
          }

          AF.request(urlRequest, method: method, parameters: params, encoding: URLEncoding.queryString, headers: httpHeaders)
              .validate(statusCode: 200..<300)
              .validate(contentType: ["application/json"])
              .responseDecodable(of: T.self) { response in
                  switch response.result {
                  case .success(let value):
                      // FixME 
//                      if let data = response.data {
//                          APICacheManager.shared.setCache(for: request.endpoint, url: request.urlAndToken, data: data)
//                      }
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
                      completion(.failure(error))
                  }
              }
      }
    
    public func execute<T: Codable>(
        _ request: MovieRequest,
        expecting type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if let cachedData = cacheManager.cachedResponse(for: request.endpoint,
                                                        url: request.urlAndToken) {
            do {
                let result = try JSONDecoder().decode(type.self, from: cachedData)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
            return
        }
        
        guard let urlRequest = request.url else {
            completion(.failure(AFError.failedToCreateRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? AFError.failedToGetData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(type.self, from: data)
                self?.cacheManager.setCache(for: request.endpoint,
                                            url: request.urlAndToken,
                                            data: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}

