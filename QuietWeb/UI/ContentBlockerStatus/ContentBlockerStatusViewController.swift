//
//  ContentBlockerStatusViewController.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/19/24.
//

import UIKit
import Combine
import AVKit
import AVFoundation

class ContentBlockerStatusViewController: NiblessViewController {
    
    let viewModel: ContentBlockerStatusViewModel
    var subscriptions = Set<AnyCancellable>()
    
    // child vc
    var tutorialVideoViewController: AVPlayerViewController?
    
    // factory
    let makeTutorialVideoViewController: () -> AVPlayerViewController
    
    init(viewModel: ContentBlockerStatusViewModel, tutorialVideoViewControllerFactory: @escaping () -> AVPlayerViewController) {
        self.viewModel = viewModel
        self.makeTutorialVideoViewController = tutorialVideoViewControllerFactory
        super.init()
        addObservers()
        setupBindings()
    }
    
    override func loadView() {
        view = ContentBlockerStatusRootView(viewModel: viewModel)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(contentBlockerEnabled), name: .contentBlockerDidBecomeEnabled, object: nil)
    }
    
    @objc func contentBlockerEnabled() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
        print("dismiss content blocker status vc")
    }
    
    private func setupBindings() {
        viewModel.presentTutorialVideoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentTutorialVideoViewController()
            }
            .store(in: &subscriptions)
    }
    
    private func presentTutorialVideoViewController() {
        if let _ = tutorialVideoViewController {
            tutorialVideoViewController = nil
        }
        let tutorialVideoViewControllerToPresent = makeTutorialVideoViewController()
        tutorialVideoViewController = tutorialVideoViewControllerToPresent
        present(tutorialVideoViewControllerToPresent, animated: true)
    }
}
