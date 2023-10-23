//
//  Alert.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 23.10.2023.
//

import UIKit

class Alert {
    class func showNotice(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            
        })
        alert.view.layer.cornerRadius = 20
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func showNotice(viewController: UIViewController, title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        alert.view.layer.cornerRadius = 20
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func showNotice(viewController: UIViewController, title: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(action)
        alert.view.layer.cornerRadius = 20
        viewController.present(alert, animated: true, completion: nil)
    }
}
