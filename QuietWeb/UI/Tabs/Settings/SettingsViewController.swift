//
//  SettingsViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine
import WebKit

class SettingsViewController: NiblessViewController {
    
    let viewModel: SettingsViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init()
        setupNavigationBar()
        setupBindings()
    }
    
    private func setupNavigationBar() {
        title = "Settings"
        navigationItem.backButtonTitle = "Back"
    }
    
    override func loadView() {
        view = SettingsRootView(viewModel: viewModel)
    }
    
    private func setupBindings() {
        viewModel.presentURLInternal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.presentWebViewController(url: url)
            }
            .store(in: &subscriptions)
        
        viewModel.presentURLExternal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.openURL(url)
            }
            .store(in: &subscriptions)
    }
    
    private func presentWebViewController(url: URL) {
        let webViewController = WebViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

class WebViewController: NiblessViewController {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    override func loadView() {
        view = WKWebView()
    }
    
    override func viewDidLoad() {
        guard let view = view as? WKWebView else { return }
        let request = URLRequest(url: url)
        view.load(request)
    }
}
