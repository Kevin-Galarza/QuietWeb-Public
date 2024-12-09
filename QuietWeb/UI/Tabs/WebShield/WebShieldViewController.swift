//
//  WebShieldViewController.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import UIKit
import Combine

class WebShieldViewController: NiblessViewController {
    
    let viewModel: WebShieldViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: WebShieldViewModel) {
        self.viewModel = viewModel
        super.init()
        setupNavigationBar()
    }
    
    override func loadView() {
        view = WebShieldRootView(viewModel: viewModel)
    }
    
    private func setupNavigationBar() {
        title = "Web Shield"
    }
}
