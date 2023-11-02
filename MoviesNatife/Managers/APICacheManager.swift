//
//  APICacheManager.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation
import Cache

/// Manages in memory session scoped API caches
final class APICacheManager {
    static let shared = APICacheManager()
    
    private let diskConfig = DiskConfig(
        name: "MoviesResponse",
        expiry: .never
    )
    private let memoryConfig = MemoryConfig(
        expiry: .never,
        countLimit: 20,
        totalCostLimit: 10
    )
    
    private var storage: Storage<String, MoviesResponse>?
    
    init() {
        do {
            storage = try Storage(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: TransformerFactory.forCodable(ofType: MoviesResponse.self)
            )
        } catch {
            print("Failed to initialize storage: \(error)")
        }
    }
    
    func getCachedResponse<T: Codable>(for key: String, completion: @escaping AlamofireResultCallback<T>) {
        guard let storage = storage else {
            completion(.failure(AFError.failedToCache))
            return
        }
        
        if let cachedData = try? storage.object(forKey: key) as? T {
            completion(.success(cachedData))
        } else {
            completion(.failure(AFError.failedToCache))
        }
    }
    
    // MARK: Private
    func cacheResponse(_ data: MoviesResponse, for key: String) {
        do {
            try storage?.setObject(data, forKey: key)
        } catch {
            print("Failed to cache response: \(error)")
        }
    }
}
