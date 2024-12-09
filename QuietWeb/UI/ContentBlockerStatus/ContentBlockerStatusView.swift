//
//  ContentBlockerStatusView.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/19/24.
//

import UIKit
import Combine

class ContentBlockerStatusRootView: NiblessView {
    
    let viewModel: ContentBlockerStatusViewModel
    
    let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Enable Quiet Web for Safari"
        label.textColor = Color.systemBlackText
        label.font = .boldSystemFont(ofSize: 20)
        label.sizeToFit()
        return label
    }()
    
    let instruction1: CBStatusInstructionView = {
        let label = UILabel()
        let fullText = "Open Settings."
        let boldText = "Settings"
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: Color.systemBlackText
        ])
        
        if let range = fullText.range(of: boldText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: nsRange)
        }
        
        label.attributedText = attributedString
        label.sizeToFit()
        label.numberOfLines = 0
        
        let icon = UIImageView(image: UIImage(named: "settings-icon"))
        
        let instructionView = CBStatusInstructionView(icon: icon, label: label)
        
        return instructionView
    }()
    
    let instruction2: CBStatusInstructionView = {
        let label = UILabel()
        let fullText = "Inside of Settings go to Safari > Extensions"
        let boldText = "Safari > Extensions"
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: Color.systemBlackText
        ])
        
        if let range = fullText.range(of: boldText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: nsRange)
        }
        
        label.attributedText = attributedString
        label.sizeToFit()
        label.numberOfLines = 0
        
        let icon = UIImageView(image: UIImage(named: "safari-icon"))
        
        let instructionView = CBStatusInstructionView(icon: icon, label: label)
        
        return instructionView
    }()
    
    let instruction3: CBStatusInstructionView = {
        let label = UILabel()
        let fullText = "Set the Quiet Web toggle to on. You're ready to start blocking distractions!"
        let boldText = "on"
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: Color.systemBlackText
        ])
        
        if let range = fullText.range(of: boldText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 15), range: nsRange)
        }
        
        label.attributedText = attributedString
        label.sizeToFit()
        label.numberOfLines = 0
        
        let icon = UIImageView(image: UIImage(named: "toggle-icon"))
        
        let instructionView = CBStatusInstructionView(icon: icon, label: label)
        
        return instructionView
    }()
    
    let tutorialButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitle("Watch Tutorial", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = Color.primaryGreen
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(frame: CGRect = .zero, viewModel: ContentBlockerStatusViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
    }
    
    func applyStyle() {
        backgroundColor = Color.primaryBackground
    }
    
    func constructHierarchy() {
        addSubview(headingLabel)
        addSubview(instruction1)
        addSubview(instruction2)
        addSubview(instruction3)
        addSubview(tutorialButton)
    }
    
    func applyConstraints() {
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        instruction1.translatesAutoresizingMaskIntoConstraints = false
        instruction2.translatesAutoresizingMaskIntoConstraints = false
        instruction3.translatesAutoresizingMaskIntoConstraints = false
        tutorialButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 60),
            headingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            
            instruction1.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 36),
            instruction1.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            instruction1.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            instruction2.topAnchor.constraint(equalTo: instruction1.bottomAnchor, constant: 24),
            instruction2.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            instruction2.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            instruction3.topAnchor.constraint(equalTo: instruction2.bottomAnchor, constant: 24),
            instruction3.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            instruction3.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            tutorialButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
            tutorialButton.heightAnchor.constraint(equalToConstant: 50),
            tutorialButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tutorialButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func buttonTapped() {
        viewModel.presentTutorialVideo()
    }
}

class CBStatusInstructionView: NiblessView {
    
    let icon: UIImageView
    let label: UILabel
    
    init(frame: CGRect = .zero, icon: UIImageView, label: UILabel) {
        self.icon = icon
        self.label = label
        super.init(frame: frame)
        layoutView()
    }
    
    private func layoutView() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .equalCentering
        stack.addArrangedSubview(icon)
        stack.addArrangedSubview(label)
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
