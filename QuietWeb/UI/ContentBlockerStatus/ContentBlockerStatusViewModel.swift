//
//  ContentBlockerStatusViewModel.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/19/24.
//

import Foundation
import Combine

class ContentBlockerStatusViewModel {
    
    let presentTutorialVideoPublisher = PassthroughSubject<Void, Never>()
    
    func presentTutorialVideo() {
        presentTutorialVideoPublisher.send()
    }
}
