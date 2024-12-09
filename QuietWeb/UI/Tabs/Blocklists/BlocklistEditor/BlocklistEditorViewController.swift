//
//  BlocklistEditorViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import UIKit
import Combine

class BlocklistEditorViewController: NiblessViewController {
    
    let viewModel: BlocklistEditorViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    // child view controller
    var websiteSelectionViewController: UIViewController?
    
    // factory
    let makeWebsiteSelectionViewController: (DistractionSelectionResponder, DistractionSelectionDataProvider) -> DistractionSelectionViewController
    
    init(viewModel: BlocklistEditorViewModel, websiteSelectionViewControllerFactory: @escaping (DistractionSelectionResponder, DistractionSelectionDataProvider) -> DistractionSelectionViewController) {
        self.viewModel = viewModel
        self.makeWebsiteSelectionViewController = websiteSelectionViewControllerFactory
        super.init()
        if viewModel.mode == .create {
            title = "Create Blocklist"
        } else {
            title = "Edit Blocklist"
        }
        setupBindings()
    }
    
    override func loadView() {
        view = BlocklistEditorRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        haptics.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    private func setupBindings() {
        viewModel.dismissBlocklistEditorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
        
        viewModel.presentWebsiteSelectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.presentWebsiteSelectionController(responder: self.viewModel, provider: self.viewModel)
            }
            .store(in: &subscriptions)
    }
    
    private func presentWebsiteSelectionController(responder: DistractionSelectionResponder, provider: DistractionSelectionDataProvider) {
        if let _ = websiteSelectionViewController {
            websiteSelectionViewController = nil
        }
        let websiteSelectionViewControllerToPresent = UINavigationController(rootViewController: makeWebsiteSelectionViewController(responder, provider))
        websiteSelectionViewControllerToPresent.modalPresentationStyle = .pageSheet
        websiteSelectionViewController = websiteSelectionViewControllerToPresent
        present(websiteSelectionViewControllerToPresent, animated: true)
    }
    
    private func dismiss() {
        haptics.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
}
