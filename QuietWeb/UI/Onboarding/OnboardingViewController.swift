//
//  OnboardingViewController.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit
import Combine
import AVKit
import AVFoundation

class OnboardingViewController: NiblessViewController {
    
    let viewModel: OnboardingViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    // child vc
    var tutorialVideoViewController: AVPlayerViewController?
    
    // factory
    let makeTutorialVideoViewController: () -> AVPlayerViewController
    
    init(viewModel: OnboardingViewModel, tutorialVideoViewControllerFactory: @escaping () -> AVPlayerViewController) {
        self.viewModel = viewModel
        self.makeTutorialVideoViewController = tutorialVideoViewControllerFactory
        super.init()
        setupBindings()
    }
    
    override func loadView() {
        view = OnboardingRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupBindings() {
        viewModel.dismissPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
        
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
    
    private func dismiss() {
        dismiss(animated: true)
        ContentBlockerManager.postStatus(identifier: ContentBlockerIdentifier.distractionBlockerIdentifier)
    }
}
