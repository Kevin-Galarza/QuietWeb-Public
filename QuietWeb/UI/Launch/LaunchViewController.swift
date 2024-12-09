//
//  LaunchViewController.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit
import Combine

class LaunchViewController: NiblessViewController {

    let viewModel: LaunchViewModel
    private var subscriptions = Set<AnyCancellable>()

    init(launchViewModelFactory: LaunchViewModelFactory) {
        self.viewModel = launchViewModelFactory.makeLaunchViewModel()
        super.init()
    }

    override func loadView() {
        view = LaunchRootView(viewModel: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        observeErrorMessages()
    }

    func observeErrorMessages() {
        viewModel.errorMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let strongSelf = self else { return }
                strongSelf.present(errorMessage: errorMessage,withPresentationState: strongSelf.viewModel.errorPresentation)
            }
            .store(in: &subscriptions)
    }
}

protocol LaunchViewModelFactory {
    func makeLaunchViewModel() -> LaunchViewModel
}
