//
//  SystemWebsiteInfoRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/15/24.
//

import UIKit
import Combine

class DistractionSourceSelectionRootView: NiblessView {
    
    let viewModel: DistractionSourceSelectionViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    init(frame: CGRect = .zero, viewModel: DistractionSourceSelectionViewModel) {
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
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WebsiteSelectionTableViewCell.self, forCellReuseIdentifier: "SelectionCell")
        
        viewModel.refreshPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
    }
    
    @objc func bulkSelectTapped(_ sender: UIButton) {
        viewModel.handleSourceToggleAll()
    }
}

extension DistractionSourceSelectionRootView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! WebsiteSelectionTableViewCell
        let source = viewModel.sources[indexPath.row]
        
        cell.textLabel?.text = source.name
        cell.setSelectionState(isSelected: viewModel.sourceIsSelected(index: indexPath.row))
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        cell.tintColor = Color.primaryGreen
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WebsiteSelectionTableViewCell
        viewModel.handleSourceToggle(index: indexPath.row)
        cell.setSelectionState(isSelected: viewModel.sourceIsSelected(index: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let selectAllButton = UIButton(type: .system)
        let title = viewModel.bulkToggleState.rawValue
        selectAllButton.setTitle(title, for: .normal)
        selectAllButton.tintColor = Color.primaryGreen
        selectAllButton.addTarget(self, action: #selector(bulkSelectTapped(_:)), for: .touchUpInside)
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView()
        headerView.backgroundColor = Color.primaryBackground
        headerView.addSubview(selectAllButton)
        
        NSLayoutConstraint.activate([
            selectAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            selectAllButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16)
        ])
        
        return headerView
    }
}
