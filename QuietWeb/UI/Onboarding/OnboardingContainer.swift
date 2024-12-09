//
//  OnboardingContainer.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import Foundation
import AVKit
import AVFoundation

class OnboardingContainer {
    
    let sharedMainViewModel: MainViewModel
    let sharedOnboardingViewModel: OnboardingViewModel
    
    init(appContainer: AppContainer) {
        func makeOnboardingViewModel() -> OnboardingViewModel {
            return OnboardingViewModel(signedInResponder: appContainer.sharedMainViewModel)
        }
        self.sharedMainViewModel = appContainer.sharedMainViewModel
        self.sharedOnboardingViewModel = makeOnboardingViewModel()
    }
    
    func makeOnboardingViewController() -> OnboardingViewController {
        let tutorialVideoFactory = { () -> AVPlayerViewController in
            return self.makeTutorialVideoViewController()
        }
        
        return OnboardingViewController(viewModel: sharedOnboardingViewModel, tutorialVideoViewControllerFactory: tutorialVideoFactory)
    }
    
    // MARK: Onboarding Tutorial Video
    
    func makeTutorialVideoViewController() -> AVPlayerViewController {
        guard let url = URL(string: "") else { return AVPlayerViewController() }
        let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        return playerViewController
    }

}
