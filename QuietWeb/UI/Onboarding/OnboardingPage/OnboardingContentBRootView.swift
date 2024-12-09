//
//  OnboardingPageBRootView.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/14/24.
//

import UIKit

class OnboardingContentBRootView: NiblessView {
    
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding-image-3"))
        return imageView
    }()
    
    let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Getting Started is Easy"
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.sizeToFit()
        label.textColor = .white
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a blocklist, add distracting websites, and schedule a session to enforce your blocklist."
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        label.textColor = Color.secondaryTextGray
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
    }
    
    private func applyStyle() {
        
    }
    
    private func constructHierarchy() {
        addSubview(imageView)
        addSubview(headingLabel)
        addSubview(bodyLabel)
    }
    
    private func applyConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 324),
            imageView.heightAnchor.constraint(equalToConstant: 202),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            bodyLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -64),
            bodyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -198),
            
            headingLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -72),
            headingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headingLabel.bottomAnchor.constraint(equalTo: bodyLabel.topAnchor, constant: -16)
        ])
    }
}
