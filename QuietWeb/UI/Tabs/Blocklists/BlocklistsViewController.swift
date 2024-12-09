//
//  BlocklistsViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine

class BlocklistsViewController: NiblessViewController {
    
    let viewModel: BlocklistsViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    // child view controller
    var blocklistEditorViewController: BlocklistEditorViewController?
    
    // factory
    let makeBlocklistEditorViewController: (BlocklistEditorPresentationMode) -> BlocklistEditorViewController
    
    init(viewModel: BlocklistsViewModel, blocklistEditorViewControllerFactory: @escaping (BlocklistEditorPresentationMode) -> BlocklistEditorViewController) {
        self.viewModel = viewModel
        self.makeBlocklistEditorViewController = blocklistEditorViewControllerFactory
        super.init()
        setupNavigationBar()
        setupBindings()
    }
    
    override func loadView() {
        view = BlocklistsRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        haptics.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    private func setupBindings() {
        viewModel.presentBlocklistEditorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.presentBlocklistEditorViewController(mode: mode)
            }
            .store(in: &subscriptions)
        
        viewModel.dismissPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
        
        viewModel.confirmDeleteBlocklistPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blocklist in
                self?.presentConfirmDeleteBlocklistAlert(blocklist: blocklist)
            }
            .store(in: &subscriptions)
    }
    
    private func setupNavigationBar() {
        if viewModel.mode == .view {
            title = "Blocklists"
            let image = UIImage(systemName: "plus.circle.fill")
            let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
            rightButton.tintColor = .white
            navigationItem.rightBarButtonItem = rightButton
        } else {
            title = "Select Blocklists"
        }
        navigationItem.backButtonTitle = "Back"
    }

    @objc private func addButtonTapped() {
        viewModel.addBlocklist()
    }
    
    func presentBlocklistEditorViewController(mode: BlocklistEditorPresentationMode) {
        if let _ = blocklistEditorViewController {
            blocklistEditorViewController = nil
        }
        let blocklistEditorViewControllerToPresent = makeBlocklistEditorViewController(mode)
        blocklistEditorViewController = blocklistEditorViewControllerToPresent
        navigationController?.pushViewController(blocklistEditorViewControllerToPresent, animated: true)
    }
    
    func presentConfirmDeleteBlocklistAlert(blocklist: Blocklist) {
        let alertController = UIAlertController(title: "Delete Blocklist", message: "Are you sure you want to permanently delete \(blocklist.name)?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteBlocklist(id: blocklist._id)
            self?.haptics.impactOccurred()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    func dismiss() {
        haptics.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
}
