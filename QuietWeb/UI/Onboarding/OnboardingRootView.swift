//
//  OnboardingRootView.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit
import Combine

class OnboardingRootView: NiblessView, UIScrollViewDelegate {
    
    let viewModel: OnboardingViewModel
    private var subscriptions = Set<AnyCancellable>()

    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    
    var didCompleteInitialLayout = false
    
    let startButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitle("Start Focusing", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Color.primaryGreen
        button.layer.cornerRadius = 12
        return button
    }()
    
    let tutorialButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "See how it works"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont(name: "Inter-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
            return outgoing
        }

        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let symbolImage = UIImage(systemName: "play.circle", withConfiguration: symbolConfiguration)
        config.image = symbolImage
        config.imagePlacement = .leading
        config.imagePadding = 6
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        button.configuration = config
        button.tintColor = Color.primaryGreen
        button.sizeToFit()
        
        return button
    }()
    
    init(frame: CGRect = .zero, viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didCompleteInitialLayout {
            didCompleteInitialLayout = true
            self.layer.sublayers?.first?.frame = self.bounds
            setupScrollView()
            setupPageControl()
        }
    }
    
    private func applyStyle() {
        backgroundColor = .black
        setupGradientBackground()
    }
    
    private func constructHierarchy() {
        addSubview(scrollView)
        addSubview(startButton)
        addSubview(tutorialButton)
        addSubview(pageControl)
    }

    func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        let page1 = OnboardingContentARootView()
        let page2 = OnboardingContentBRootView()
        let page3 = OnboardingContentCRootView()

        let pages = [page1, page2, page3]

        for (index, page) in pages.enumerated() {
            page.frame = CGRect(x: self.bounds.width * CGFloat(index), y: 0, width: self.bounds.width, height: self.bounds.height)
            scrollView.addSubview(page)
        }

        scrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(pages.count), height: self.bounds.height)
    }

    func setupPageControl() {
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    private func applyConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        tutorialButton.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            startButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            tutorialButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tutorialButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            
            pageControl.heightAnchor.constraint(equalToConstant: 50),
            pageControl.widthAnchor.constraint(equalTo: widthAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor)
        ])
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds

        gradientLayer.colors = [
            Color.primaryBlue.cgColor,
            Color.secondaryBlue.cgColor
        ]

        // Set the direction of the gradient (vertical)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Bottom-center

        // Add the gradient layer to the view's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    // UIScrollViewDelegate method to detect scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    @objc func startButtonTapped() {
        viewModel.dismiss()
    }
    
    @objc func tutorialButtonTapped() {
        viewModel.presentTutorialVideo()
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let page: Int = sender.currentPage
        let offset = CGPoint(x: CGFloat(page) * scrollView.frame.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
}
