//
//  GenresResponse.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 26.10.2023.
//

import Foundation

struct GenresResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
