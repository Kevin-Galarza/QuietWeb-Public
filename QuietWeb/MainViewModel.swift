//
//  MainViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import Combine

class MainViewModel: SignedInResponder, NotSignedInResponder {

    @Published public private(set) var view: MainView = .launching

    init() {}

    func notSignedIn() {
        view = .onboarding
    }

    func signedIn() {
        view = .signedIn
    }
}
