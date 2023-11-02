//
//  ImageViewController.swift
//  MoviesNatife
//
//  Created by Ivan Potapenko on 29.10.2023.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Properties
    private var imageView = UIImageView()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var lastZoomPoint: CGPoint?
    
    // MARK: - Lifecycle
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView = UIImageView(image: image)
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
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        scrollView.addSubview(imageView)
        imageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    private func addGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scrollView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scrollView.addGestureRecognizer(panGesture)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - Actions
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let scale = sender.scale
            scrollView.zoomScale *= scale
            sender.scale = 1.0
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            let translation = sender.translation(in: view)
            if let view = sender.view {
                let xOffset = scrollView.contentOffset.x - translation.x
                let yOffset = scrollView.contentOffset.y - translation.y
                scrollView.setContentOffset(CGPoint(x: xOffset, y: yOffset), animated: false)
            }
            sender.setTranslation(CGPoint.zero, in: view)
        }
    }
}
