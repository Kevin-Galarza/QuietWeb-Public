//
//  SystemWebsiteInfoViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/15/24.
//

import UIKit
import Combine

class DistractionSourceSelectionViewController: NiblessViewController {
    
    let viewModel: DistractionSourceSelectionViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    init(viewModel: DistractionSourceSelectionViewModel) {
        self.viewModel = viewModel
        super.init()
        setupBindings()
    }
    
    override func viewDidLoad() {
        haptics.prepare()
        
        title = viewModel.distractionGroup.name
        
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
        view = DistractionSourceSelectionRootView(viewModel: viewModel)
    }
    
    private func setupBindings() {
        viewModel.dismissPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss()
            }
            .store(in: &subscriptions)
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
}
