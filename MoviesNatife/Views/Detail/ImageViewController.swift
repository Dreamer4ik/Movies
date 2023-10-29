//
//  ImageViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

class ImageViewController: UIViewController {
    // MARK: - Properties
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Lifecycle
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        addGestures()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.frame = view.bounds
    }
    
    private func addGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.direction = .down
        
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(swipeGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let currentScale = imageView.frame.size.width / imageView.bounds.size.width
            let newScale = currentScale * sender.scale
            let transform = CGAffineTransform(scaleX: newScale, y: newScale)
            imageView.transform = transform
            sender.scale = 1
        } else if sender.state == .ended {
            imageView.transform = .identity
        }
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}
