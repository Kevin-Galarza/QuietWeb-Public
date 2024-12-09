//
//  SessionEditorViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import UIKit
import Combine

class SessionEditorViewController: NiblessViewController {
    
    let viewModel: SessionEditorViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    // child view controller
    var blocklistsViewController: BlocklistsViewController?
    var recurringDaysSelectionViewController: UIViewController?
    
    // factory
    let makeBlocklistsViewController: (BlocklistsPresentationMode, BlocklistSelectionResponder) -> BlocklistsViewController
    let makeRecurringDaysSelectionViewController: (RecurringDaysSelectionResponder, RecurringDaysSelectionProvider) -> RecurringDaysSelectionViewController
    
    init(viewModel: SessionEditorViewModel, blocklistsViewControllerFactory: @escaping (BlocklistsPresentationMode, BlocklistSelectionResponder) -> BlocklistsViewController, recurringDaysSelectionViewControllerFactory: @escaping (RecurringDaysSelectionResponder, RecurringDaysSelectionProvider) -> RecurringDaysSelectionViewController) {
        self.viewModel = viewModel
        self.makeBlocklistsViewController = blocklistsViewControllerFactory
        self.makeRecurringDaysSelectionViewController = recurringDaysSelectionViewControllerFactory
        super.init()
        if viewModel.mode == .create {
            title = "Create Session"
        } else if case .edit = viewModel.mode {
            title = "Edit Session"
        } else if case .view = viewModel.mode {
            title = "View Session"
        }
        navigationItem.backButtonTitle = "Back"
        setupBindings()
    }
    
    override func loadView() {
        view = SessionEditorRootView(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        haptics.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    private func setupBindings() {
        viewModel.presentBlocklistsViewControllerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.presentBlocklistsViewController(mode: mode)
            }
            .store(in: &subscriptions)
        
        viewModel.presentRecurringDaysSelectionViewControllerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.presentRecurringDaysSelectionViewController(provider: self.viewModel, responder: self.viewModel)
            }
            .store(in: &subscriptions)
        
        viewModel.invalidTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentInvalidTimeAlert()
            }
            .store(in: &subscriptions)
        
        viewModel.dismissPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
        
        viewModel.verifySavePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (endDate, type) in
                self?.presentVerifySaveAlert(date: endDate, type: type)
            }
            .store(in: &subscriptions)
    }
    
    private func presentInvalidTimeAlert() {
        let alertController = UIAlertController(title: "Invalid Time Selection", message: "The times you selected are invalid.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentVerifySaveAlert(date: Date, type: SessionType) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
        
        let dateString = dateFormatter.string(from: date)
        
        let alertController = UIAlertController(
            title: "Are You Sure?",
            message: type == .now ? "Blocking will begin immediately and cannot be stopped until \(dateString)" : "You will be reminded to start the session at the scheduled time(s). Once blocking begins, it cannot be stopped until the session completes.",
            preferredStyle: .alert
        )

        let continueAction = UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.viewModel.save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(continueAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = Color.primaryGreen

        present(alertController, animated: true, completion: nil)
    }
    
    private func presentBlocklistsViewController(mode: BlocklistsPresentationMode) {
        if let _ = blocklistsViewController {
            blocklistsViewController = nil
        }
        let blocklistViewControllerToPresent = makeBlocklistsViewController(mode, viewModel)
        blocklistsViewController = blocklistViewControllerToPresent
        navigationController?.pushViewController(blocklistViewControllerToPresent, animated: true)
    }
    
    private func presentRecurringDaysSelectionViewController(provider: RecurringDaysSelectionProvider, responder: RecurringDaysSelectionResponder) {
        if let _ = recurringDaysSelectionViewController {
            recurringDaysSelectionViewController = nil
        }
        let recurringDaysSelectionViewControllerToPresent = UINavigationController(rootViewController: makeRecurringDaysSelectionViewController(responder, provider))
        recurringDaysSelectionViewControllerToPresent.modalPresentationStyle = .pageSheet
        recurringDaysSelectionViewController = recurringDaysSelectionViewControllerToPresent
        present(recurringDaysSelectionViewControllerToPresent, animated: true)
    }
    
    private func dismiss() {
        haptics.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
}
