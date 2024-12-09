//
//  WebsiteSelectionViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import UIKit
import Combine

class DistractionSelectionViewController: NiblessViewController {
    
    let viewModel: DistractionSelectionViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    // child view controller
    var systemWebsiteInfoViewController: UIViewController?
    
    // factory
    let makeSystemWebsiteInfoViewController: (DistractionSourceSelectionResponder, DistractionSourceSelectionDataProvider, DistractionGroup) -> DistractionSourceSelectionViewController
    
    init(viewModel: DistractionSelectionViewModel, systemWebsiteInfoViewControllerFactory: @escaping (DistractionSourceSelectionResponder, DistractionSourceSelectionDataProvider, DistractionGroup) -> DistractionSourceSelectionViewController) {
        self.viewModel = viewModel
        self.makeSystemWebsiteInfoViewController = systemWebsiteInfoViewControllerFactory
        super.init()
        setupBindings()
    }
    
    override func viewDidLoad() {
        haptics.prepare()
        
        title = "Select Distractions"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        cancelButton.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        saveButton.setTitleTextAttributes([.foregroundColor: Color.primaryGreen], for: .normal)
        navigationItem.rightBarButtonItem = saveButton
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Color.primaryBackground
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func loadView() {
        view = DistractionSelectionRootView(viewModel: viewModel)
    }
    
    func setupBindings() {
        viewModel.dismissPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
        
        viewModel.presentSystemWebsiteInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (responder, provider, group) in
                self?.presentSystemWebsiteInfo(responder: responder, provider: provider, distractionGroup: group)
            }
            .store(in: &subscriptions)
        
        viewModel.presentUserWebsiteEditorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] website in
                self?.presentUserWebsiteEditor(website: website)
            }
            .store(in: &subscriptions)
    }
    
    private func presentUserWebsiteEditor(website: String?) {
        let isEditing = (website != nil)
        let title = isEditing ? "Edit Website" : "Add Website"
        let message = isEditing ? "Edit the website you want to block." : "Add a website you want to block."
        let confirmButtonTitle = isEditing ? "Update" : "Add"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = Color.primaryGreen
        
        alertController.addTextField { textField in
            textField.placeholder = "facebook.com"
            textField.text = website
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            // Add a target to observe text changes
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        
        let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let newWebsite = textField.text, !newWebsite.isEmpty else { return }
            if isEditing {
                self?.viewModel.softUpdateUserDistraction(oldWebsite: website ?? "", newWebsite: newWebsite)
            } else {
                self?.viewModel.softAddUserDistraction(newWebsite)
            }
        }
        
        confirmAction.isEnabled = false // Initially disable the confirm action
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true) {
            alertController.textFields?.first?.becomeFirstResponder()
        }
    }
    
    private func presentSystemWebsiteInfo(responder: DistractionSourceSelectionResponder, provider: DistractionSourceSelectionDataProvider, distractionGroup: DistractionGroup) {
        if let _ = systemWebsiteInfoViewController {
            systemWebsiteInfoViewController = nil
        }
        let systemWebsiteInfoViewControllerToPresent = UINavigationController(rootViewController: makeSystemWebsiteInfoViewController(responder, provider, distractionGroup))
        systemWebsiteInfoViewControllerToPresent.modalPresentationStyle = .pageSheet
        systemWebsiteInfoViewController = systemWebsiteInfoViewControllerToPresent
        present(systemWebsiteInfoViewControllerToPresent, animated: true)
    }
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        viewModel.dismiss()
    }
    
    @objc private func saveTapped() {
        haptics.impactOccurred()
        viewModel.save()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let alertController = self.presentedViewController as? UIAlertController,
              let confirmAction = alertController.actions.last,
              let urlString = textField.text else {
            return
        }
        
        confirmAction.isEnabled = viewModel.isValidContentBlockerURL(urlString)
    }
}
