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
    "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNzhhYzhkZjM5MDhlODJlZTZkODU1YjYwNDJkMWZmMiIsInN1YiI6IjYyZDkzNzcwMGQ5ZjVhMDA1M2M4YjFhZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.JzzoVoplNYboBwBocwL0tdKfoaXHvs0y54N3bXfBzvc"
]


enum AlamofireHelperNetworkResult<T: Codable> {
    case success(T)
    case failure(String)
}

typealias AlamofireResultCallback<T: Codable> = (AlamofireHelperNetworkResult<T>) -> Void

class AlamofireHelper: NSObject {
    class func sendRequest<T: Codable>(
        expecting type: T.Type,
        endpoint: String,
        from viewController: UIViewController,
        method: HTTPMethod,
        params: Parameters?,
        completionHandler: @escaping AlamofireResultCallback<T>,
        needToShowAlertOnError: Bool = true
    ) {
        guard Network.reachability?.isReachable == true else {
            // Handle no internet connection
            Alert.showNotice(viewController: viewController, title: "Offline", message: "You are offline. Please enable your Wi-Fi or connect using cellular data.")
            return
        }
        AF.request("\(baseUrl)\(endpoint)", method: method, parameters: params, encoding: URLEncoding.queryString, headers: httpHeaders)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: T.self) { (response: DataResponse<T, AFError>) in
                
                switch response.result {
                case .success(let value):
                    completionHandler(.success(value))
                    
                case .failure(let error):
                    guard let data = response.data,
                          let message = try? JSONDecoder().decode(String.self, from: data) else {
                        completionHandler(.failure(error.localizedDescription))
                        return
                    }
                    
                    if needToShowAlertOnError {
                        // check Server Side Error Message
                    }
                    
                    completionHandler(.failure(message))
                }
            }
    }
}

