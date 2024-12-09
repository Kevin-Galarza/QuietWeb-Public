//
//  LaunchViewModel.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import Foundation
import Combine

class LaunchViewModel {

    let notSignedInResponder: NotSignedInResponder
    let signedInResponder: SignedInResponder
//    let webShieldRepository: WebShieldRepository
    let blocklistCoordinator: BlocklistCoordinator

    var errorMessages: AnyPublisher<ErrorMessage, Never> {
        errorMessagesSubject.eraseToAnyPublisher()
    }
    private let errorMessagesSubject = PassthroughSubject<ErrorMessage,Never>()
    let errorPresentation = PassthroughSubject<ErrorPresentation?, Never>()
    private var subscriptions = Set<AnyCancellable>()

    init(notSignedInResponder: NotSignedInResponder, signedInResponder: SignedInResponder, blocklistCoordinator: BlocklistCoordinator) {
        self.notSignedInResponder = notSignedInResponder
        self.signedInResponder = signedInResponder
//        self.webShieldRepository = webShieldRepository
        self.blocklistCoordinator = blocklistCoordinator
//        preloadContentBlockerIfNeeded()
    }
    
    // TODO: Call this from the onboarding scope instead
//    func preloadContentBlockerIfNeeded() {
//        do {
//            if try webShieldRepository.read().first == nil {
//                let webShield = WebShield()
//                webShield.enabledWebShieldGroups.append(objectsIn: [.ads, .privacy, .security])
//                webShield.enabledWebShieldBlocklists.append(objectsIn: [.adsBase, .adsMobile, .privacyBase, .easyPrivacy, .peterLowe, .securityPhishing, .securityScams, .securityMalware])
//                try webShieldRepository.create(webShield: webShield)
//                blocklistCoordinator.handleBlocklistUpdate(for: .webShield(.ads))
//                blocklistCoordinator.handleBlocklistUpdate(for: .webShield(.privacy))
//                blocklistCoordinator.handleBlocklistUpdate(for: .webShield(.security))
//            }
//        } catch {
//            print("Error preloading content blocker at launch: \(error)")
//        }
//    }
    
    func loadNewUserFlag() -> Bool {
        let userDefaults = UserDefaults.standard
        let key = "isFirstTimeUser"

        if userDefaults.object(forKey: key) == nil {
            // Key doesn't exist, so this is the first time user
            userDefaults.set(false, forKey: key)
            return true
        } else {
            return userDefaults.bool(forKey: key)
        }
    }

    func present(errorMessage: ErrorMessage) {
        goToNextScreenAfterErrorPresentation()
        errorMessagesSubject.send(errorMessage)
    }

    func goToNextScreenAfterErrorPresentation() {
        errorPresentation
            .filter { $0 == .dismissed }
            .prefix(1)
            .sink { [weak self] _ in
                self?.goToNextScreen(isNewUser: true)
            }
            .store(in: &subscriptions)
    }

    func goToNextScreen(isNewUser: Bool) {
        switch isNewUser {
        case true:
            notSignedInResponder.notSignedIn()
        case false:
            signedInResponder.signedIn()
        }
    }
}
