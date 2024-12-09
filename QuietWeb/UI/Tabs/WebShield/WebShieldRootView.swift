//
//  WebShieldRootView.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import UIKit
import Combine

class WebShieldRootView: NiblessView {
    
    let viewModel: WebShieldViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    init(frame: CGRect = .zero, viewModel: WebShieldViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
        setupBindings()
    }
    
    private func applyStyle() {
        backgroundColor = Color.primaryBackground
        tableView.backgroundColor = Color.primaryBackground
    }
    
    private func constructHierarchy() {
        addSubview(tableView)
    }
    
    private func applyConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SubtitleCell")
    }
    
    @objc private func toggleSwitchChanged(_ toggleSwitch: UISwitch) {
        switch toggleSwitch.tag {
        case 0: viewModel.toggleBlocklist(group: .ads)
        case 1: viewModel.toggleBlocklist(group: .privacy)
        case 2: viewModel.toggleBlocklist(group: .security)
        default: return
        }
    }
}

extension WebShieldRootView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath)
        
        for subview in cell.contentView.subviews {
            if subview is UITextField {
                subview.removeFromSuperview()
            }
        }
        
        let isEnabled = viewModel.groupState(for: indexPath)
        let group = viewModel.group(for: indexPath)
        
        cell.textLabel?.text = group?.name
        cell.textLabel?.textColor = Color.systemBlackText
        cell.detailTextLabel?.text = group?.description
        cell.detailTextLabel?.textColor = Color.systemGrayText
        let toggle = UISwitch(frame: .zero)
        toggle.tag = indexPath.row
        toggle.isOn = isEnabled
        toggle.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
        toggle.onTintColor = Color.primaryGreen
        cell.accessoryView = toggle
        
        return cell
    }
}
