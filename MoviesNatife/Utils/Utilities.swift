//
//  Utilities.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

final class Utilities {
    static func configureNavBar(vc: UIViewController) {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .systemBackground
        vc.navigationItem.standardAppearance = barAppearance
        vc.navigationItem.scrollEdgeAppearance = barAppearance
    }
}

