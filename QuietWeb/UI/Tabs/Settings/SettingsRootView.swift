//
//  SettingsRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine

class SettingsRootView: NiblessView {

    let viewModel: SettingsViewModel
    private var subscriptions = Set<AnyCancellable>()

    private let tableView = UITableView()

    init(frame: CGRect = .zero, viewModel: SettingsViewModel) {
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
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.$settingsSections
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(CommonTableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension SettingsRootView: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settingsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsSections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = viewModel.settingsSections[indexPath.section][indexPath.row]
        
        // Reset cell to default state to avoid reuse issues
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.textLabel?.textColor = Color.systemBlackText
        
        cell.textLabel?.text = item.title

        switch item.type {
        case .toggle(let isOn):
            let toggle = UISwitch(frame: .zero)
            toggle.isOn = isOn
            toggle.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
            toggle.onTintColor = Color.primaryGreen
            cell.accessoryView = toggle
        case .drillIn:
            let accessoryImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
            let accessoryImageView = UIImageView(image: accessoryImage)
            accessoryImageView.tintColor = Color.primaryGreen
            cell.accessoryView = accessoryImageView
        case .link:
            cell.textLabel?.textColor = Color.primaryGreen
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                viewModel.handleAbout()
            }
            if indexPath.row == 1 {
                viewModel.handleHelpCenter()
            }
            if indexPath.row == 2 {
                viewModel.handleAppReview()
            }
        case 1:
            if indexPath.row == 0 {
                viewModel.handlePrivacyPolicy()
            }
            if indexPath.row == 1 {
                viewModel.handleTerms()
            }
        default: return
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Support & Feedback"
        case 1: return "Legal & Privacy"
        default: return nil
        }
    }

    @objc private func toggleSwitchChanged(_ sender: UISwitch) {
        viewModel.allowNotifications = sender.isOn
    }
}
