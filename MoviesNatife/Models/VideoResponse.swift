//
//  VideoResponse.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import Foundation

struct VideoResponse: Codable {
    let id: Int
    let results: [Video]
}
