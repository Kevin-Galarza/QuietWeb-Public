//
//  RecurringDaysSelectionRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/19/24.
//

import UIKit
import Combine

class RecurringDaysSelectionRootView: NiblessView {
    
    let viewModel: RecurringDaysSelectionViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    init(frame: CGRect = .zero, viewModel: RecurringDaysSelectionViewModel) {
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
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.refreshTableViewPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommonTableViewCell.self, forCellReuseIdentifier: "StandardCell")
    }
}

extension RecurringDaysSelectionRootView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return WeekdaySelectionPreset.allCases.count
        case 1: return Weekday.allCases.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let preset = WeekdaySelectionPreset.allCases[indexPath.row]
            viewModel.handlePresetSelection(preset)
        } else if indexPath.section == 1 {
            let weekday = Weekday.allCases[indexPath.row]
            viewModel.handleWeekdaySelection(weekday)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Quick Select"
        case 1: return "Weekdays"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandardCell", for: indexPath)
        
        cell.textLabel?.textColor = Color.systemBlackText
        cell.tintColor = Color.primaryGreen
        cell.accessoryType = .none
        cell.textLabel?.text = ""
        
        switch indexPath.section {
        case 0:
            let preset = WeekdaySelectionPreset.allCases[indexPath.row]
            cell.textLabel?.text = preset.rawValue
            cell.accessoryType = (viewModel.selectedPreset == preset) ? .checkmark : .none
        case 1:
            let weekday = Weekday.allCases[indexPath.row]
            cell.textLabel?.text = weekday.description
            cell.accessoryType = viewModel.selectedWeekdays.contains(weekday) ? .checkmark : .none
        default:
            break
        }
        
        return cell
    }
}
