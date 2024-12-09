//
//  OnboardingViewModel.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import Foundation
import Combine

class OnboardingViewModel {
    
    let signedInResponder: SignedInResponder
    
    let dismissPublisher = PassthroughSubject<Void, Never>()
    let presentTutorialVideoPublisher = PassthroughSubject<Void, Never>()
    
    init(signedInResponder: SignedInResponder) {
        self.signedInResponder = signedInResponder
    }
    
    func dismiss() {
        signedInResponder.signedIn()
        dismissPublisher.send()
    }
    
    func presentTutorialVideo() {
        presentTutorialVideoPublisher.send()
    }
}
