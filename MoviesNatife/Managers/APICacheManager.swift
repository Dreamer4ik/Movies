//
//  APICacheManager.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 24.10.2023.
//

import Foundation
import Alamofire

/// Manages in memory session scoped API caches
final class APICacheManager { // проблема не тут
    static let shared = APICacheManager()
    
//    private var cacheDictionary: [
//        MovieEndpoint: NSCache<NSString, NSData>
//    ] = [:]
//    
//    init() {
//        setUpCache()
//    }
//    
//    // MARK: Public
//    public func cachedResponse(for endpoint: MovieEndpoint, url: URL?) -> Data? {
//        guard let targetCache = cacheDictionary[endpoint], let url = url else {
//            return nil
//        }
//
//        let key = url.absoluteString as NSString
//        let cachedData = targetCache.object(forKey: key) as? Data
//        if cachedData != nil {
//            print("Cache hit for \(endpoint)")
//        }
//        return cachedData
//    }
//    public func setCache(for endpoint: MovieEndpoint, url: URL?, data: Data) {
//        guard let targetCache = cacheDictionary[endpoint], let url = url else {
//            return
//        }
//        
//        let key = url.absoluteString as NSString
//        targetCache.setObject(data as NSData, forKey: key)
//    }
//    
//    // MARK: Private
//    private func setUpCache() {
////        cacheDictionary[MovieEndpoint.popularMovies]?.removeAllObjects()
////        print("clear")
//        MovieEndpoint.allCases.compactMap({ endpoint in
//            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
//            print("Cache initialized for \(endpoint)")
//        })
//    }
}
