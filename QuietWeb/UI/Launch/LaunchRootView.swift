//
//  LaunchRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit

class LaunchRootView: NiblessView {

    let viewModel: LaunchViewModel
    
    let logoImageView: UIImageView = {
        guard let image = UIImage(named: "logo-standard-large") else { return UIImageView() }
        let imageView = UIImageView(image: image)
        return imageView
    }()

    init(frame: CGRect = .zero, viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        styleView()
        constructHierarchy()
        activateConstraints()
        loadNewUserFlag()
    }

    private func styleView() {
        backgroundColor = Color.primaryBlue
    }
    
    private func constructHierarchy() {
        addSubview(logoImageView)
    }

    private func activateConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 256),
            logoImageView.heightAnchor.constraint(equalToConstant: 256),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func loadNewUserFlag() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            let isNewUser = self?.viewModel.loadNewUserFlag()
//            let isNewUser = true
            self?.viewModel.goToNextScreen(isNewUser: isNewUser ?? true)
        }
    }
}
