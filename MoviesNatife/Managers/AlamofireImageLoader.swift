//
//  AlamofireImageLoader.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation
import Alamofire

class AlamofireImageLoader {
    static let shared = AlamofireImageLoader()
    
    private var imageDataCache = NSCache<NSString, NSData>()
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let key = url.absoluteString as NSString
        
        // FixMe
//        if let data = imageDataCache.object(forKey: key) {
//            print("Read from cache")
//            completion(.success(data as Data))
//            return
//        }
        
        AF.request(url).responseData { [weak self] response in
            switch response.result {
            case .success(let data):
                let value = data as NSData
//                self?.imageDataCache.setObject(value, forKey: key)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
