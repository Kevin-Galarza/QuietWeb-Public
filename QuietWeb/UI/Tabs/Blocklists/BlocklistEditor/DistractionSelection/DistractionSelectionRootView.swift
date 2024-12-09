//
//  WebsiteSelectionRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import UIKit
import Combine

class DistractionSelectionRootView: NiblessView {
    
    let viewModel: DistractionSelectionViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()

    init(frame: CGRect = .zero, viewModel: DistractionSelectionViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        setupConstraints()
        setupBindings()
    }
    
    private func applyStyle() {
        backgroundColor = Color.primaryBackground
        tableView.backgroundColor = Color.primaryBackground
    }
    
    private func constructHierarchy() {
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommonTableViewCell.self, forCellReuseIdentifier: "StandardCell")
        tableView.register(WebsiteSelectionTableViewCell.self, forCellReuseIdentifier: "WebsiteSelectionCell")
        
        viewModel.$userDistractions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    @objc func cellEditButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        viewModel.presentUserWebsiteEditor(mode: .edit(index))
    }
    
    @objc func selectAllTapped(_ sender: UIButton) {
        let section = sender.tag
        viewModel.handleSelectAll(for: section)
    }
}

extension DistractionSelectionRootView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.userDistractions.isEmpty ? 1 : viewModel.userDistractions.count + 1
        case 1:
            return DistractionGroup.allCases.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
                cell.textLabel?.text = "Add a Website"
                cell.textLabel?.textColor = Color.primaryGreen
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteSelectionCell", for: indexPath) as! WebsiteSelectionTableViewCell
                cell.accessoryView = nil
                let website = viewModel.userDistractions[indexPath.row - 1]
                cell.textLabel?.text = website
                cell.setSelectionState(isSelected: viewModel.selectedUserDistractions.contains(website))
                cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
                let button = UIButton()
                button.setTitle("Edit", for: .normal)
                button.setTitleColor(Color.primaryGreen, for: .normal)
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(cellEditButtonTapped(_:)), for: .touchUpInside)
                cell.accessoryView = button
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebsiteSelectionCell", for: indexPath) as! WebsiteSelectionTableViewCell
            cell.accessoryView = nil
            let group = DistractionGroup.allCases[indexPath.row]
            cell.textLabel?.text = group.name
            cell.setSelectionState(isSelected: viewModel.selectedDistractionGroups.contains(group))
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
            cell.accessoryType = .detailButton
            cell.tintColor = Color.primaryGreen
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                viewModel.presentUserWebsiteEditor(mode: .create)
            } else {
                handleCellSelection(at: indexPath)
            }
        case 1:
            handleCellSelection(at: indexPath)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            viewModel.presentSystemWebsiteInfo(index: indexPath.row)
        default:
            break
        }
    }
    
    private func handleCellSelection(at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WebsiteSelectionTableViewCell
        if indexPath.section == 0 {
            let distraction = viewModel.userDistractions[indexPath.row - 1]
            if let index = viewModel.selectedUserDistractions.firstIndex(of: distraction) {
                viewModel.selectedUserDistractions.remove(at: index)
            } else {
                viewModel.selectedUserDistractions.insert(distraction)
            }
        } else if indexPath.section == 1 {
            let distractionGroup = DistractionGroup.allCases[indexPath.row]
            
            viewModel.handleDistractionGroupToggle(group: distractionGroup)
            
            if let index = viewModel.selectedDistractionGroups.firstIndex(of: distractionGroup) {
                viewModel.selectedDistractionGroups.remove(at: index)
            } else {
                viewModel.selectedDistractionGroups.insert(distractionGroup)
            }
        }
        cell.setSelectionState(isSelected: !cell.isCellSelected)
        viewModel.updateBulkSelectNames()
    }
    
    private func titleForSection(_ section: Int) -> String? {
        switch section {
        case 0: return "Your Distractions"
        case 1: return "Common Distractions"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel()
        titleLabel.text = titleForSection(section)
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let selectAllButton = UIButton(type: .system)
        var title = viewModel.bulkSelectNameForSection(section)
        selectAllButton.setTitle(title, for: .normal)
        selectAllButton.tintColor = Color.primaryGreen
        selectAllButton.tag = section
        selectAllButton.addTarget(self, action: #selector(selectAllTapped(_:)), for: .touchUpInside)
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView()
        headerView.backgroundColor = Color.primaryBackground
        headerView.addSubview(selectAllButton)
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16),
            selectAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            selectAllButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 && indexPath.row > 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let website = viewModel.userDistractions[indexPath.row - 1]
            viewModel.softDeleteUserDistraction(website)
        }
    }
}
