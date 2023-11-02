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
    
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }
    
}

