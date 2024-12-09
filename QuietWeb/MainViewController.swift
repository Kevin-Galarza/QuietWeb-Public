//
//  File.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import UIKit
import Combine

class MainViewController: NiblessViewController {
    
    let viewModel: MainViewModel
    
    // Child View Controllers
    let launchViewController: LaunchViewController
    var signedInViewController: SignedInViewController?
    var onboardingViewController: OnboardingViewController?

    // State
    var subscriptions = Set<AnyCancellable>()

    // Factories
    let makeOnboardingViewController: () -> OnboardingViewController
    let makeSignedInViewController: () -> SignedInViewController
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Methods
    public init(viewModel: MainViewModel,
              launchViewController: LaunchViewController,
              onboardingViewControllerFactory: @escaping () -> OnboardingViewController,
              signedInViewControllerFactory: @escaping () -> SignedInViewController) {
        self.viewModel = viewModel
        self.launchViewController = launchViewController
        self.makeOnboardingViewController = onboardingViewControllerFactory
        self.makeSignedInViewController = signedInViewControllerFactory
        super.init()
    }
    
    func subscribe(to publisher: AnyPublisher<MainView, Never>) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] view in
                guard let strongSelf = self else { return }
                strongSelf.present(view)
            }
            .store(in: &subscriptions)
    }

    func present(_ view: MainView) {
        switch view {
        case .launching:
            presentLaunching()
        case .onboarding:
            presentOnboarding()
        case .signedIn:
            presentSignedIn()
        }
    }

    func presentLaunching() {
        addFullScreen(childViewController: launchViewController)
    }

    func presentOnboarding() {
        let onboardingViewController = makeOnboardingViewController()
        onboardingViewController.modalPresentationStyle = .fullScreen
        present(onboardingViewController, animated: true) { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.remove(childViewController: strongSelf.launchViewController)
            if let signedInViewController = strongSelf.signedInViewController {
                strongSelf.remove(childViewController: signedInViewController)
                strongSelf.signedInViewController = nil
            }
        }
        self.onboardingViewController = onboardingViewController
    }

    func presentSignedIn() {
        remove(childViewController: launchViewController)

        let signedInViewControllerToPresent: SignedInViewController
        if let vc = self.signedInViewController {
            signedInViewControllerToPresent = vc
        } else {
            signedInViewControllerToPresent = makeSignedInViewController()
            self.signedInViewController = signedInViewControllerToPresent
        }

        addFullScreen(childViewController: signedInViewControllerToPresent)

        if onboardingViewController?.presentingViewController != nil {
            onboardingViewController = nil
            dismiss(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeViewModel()
    }

    private func observeViewModel() {
        let publisher = viewModel.$view.removeDuplicates().eraseToAnyPublisher()
        subscribe(to: publisher)
    }
}
