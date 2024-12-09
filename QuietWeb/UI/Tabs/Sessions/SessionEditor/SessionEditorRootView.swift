//
//  SessionEditorRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import UIKit
import Combine

class SessionEditorRootView: NiblessView {
    
    let viewModel: SessionEditorViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.setTitle("Save Session", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(Color.systemGray3, for: .disabled)
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(frame: CGRect = .zero, viewModel: SessionEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        setupConstraints()
        setupBindings()
        setupGestureRecognizers()
    }
    
    private func applyStyle() {
        backgroundColor = Color.primaryBackground
        tableView.backgroundColor = Color.primaryBackground
    }
    
    private func constructHierarchy() {
        addSubview(tableView)
        addSubview(saveButton)
        if case .view = viewModel.mode {
            saveButton.isHidden = true
        }
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SessionEditorCell")
        
        viewModel.refreshTableViewPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.savingIsEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.saveButton.setEnabled(isEnabled)
            }
            .store(in: &subscriptions)
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc private func saveButtonTapped() {
//        viewModel.save()
        viewModel.verifySave()
    }
    
    @objc private func nameChanged(_ textField: UITextField) {
        viewModel.name = textField.text ?? ""
    }
    
    @objc func timePickerChanged(_ sender: UIDatePicker) {
        viewModel.timePickerChanged(date: sender.date, tag: sender.tag)
    }
    
    private func createSessionTypeMenu() -> UIMenu {
        let nowAction = UIAction(title: "Start Now", state: viewModel.type == .now ? .on : .off) { _ in
            self.viewModel.type = .now
        }
        let laterAction = UIAction(title: "Start Later", state: viewModel.type == .later ? .on : .off) { _ in
            self.viewModel.type = .later
        }
        let recurringAction = UIAction(title: "Recurring", state: viewModel.type == .recurring ? .on : .off) { _ in
            self.viewModel.type = .recurring
        }
        
        return UIMenu(title: "", children: [nowAction, laterAction, recurringAction])
    }
}

extension SessionEditorRootView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if case .view = viewModel.mode { return viewModel.selectedBlocklists.count }
            return viewModel.selectedBlocklists.isEmpty ? 1 : viewModel.selectedBlocklists.count + 1
        case 2:
            switch viewModel.type {
            case .now: return 2
            case .later: return 3
            case .recurring: return 4
            default: return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionEditorCell", for: indexPath)
        
        for subview in cell.contentView.subviews {
            if subview is UITextField {
                subview.removeFromSuperview()
            }
        }
        
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        switch indexPath.section {
        case 0:
            let textField = UITextField()
            textField.placeholder = "Session Name"
            textField.text = viewModel.name
            textField.textColor = Color.systemBlackText
            textField.clearButtonMode = .whileEditing
            textField.delegate = self
            textField.addTarget(self, action: #selector(nameChanged(_:)), for: .editingChanged)
            textField.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                textField.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16),
                textField.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -16)
            ])
            
            if case .view = viewModel.mode {
                textField.isEnabled = false
                textField.textColor = Color.systemGray3
            }
        case 1:
            if case .view = viewModel.mode {
                cell.textLabel?.text = viewModel.blocklistNames[indexPath.row]
                cell.textLabel?.textColor = Color.systemGray3
                break
            }
            if indexPath.row == 0 {
                cell.textLabel?.text = "Add Blocklists"
                cell.textLabel?.textColor = Color.primaryGreen
                let accessoryImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
                let accessoryImageView = UIImageView(image: accessoryImage)
                accessoryImageView.tintColor = Color.primaryGreen
                cell.accessoryView = accessoryImageView
            } else {
                cell.textLabel?.text = viewModel.blocklistNames[indexPath.row - 1]
                cell.textLabel?.textColor = Color.systemBlackText
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Session Type"
                cell.textLabel?.textColor = Color.systemBlackText
                cell.detailTextLabel?.text = viewModel.type.description
                cell.detailTextLabel?.textColor = UIColor.systemGray
                let button = UIButton()
                button.setTitle(viewModel.type.name, for: .normal)
                button.setTitleColor(Color.primaryGreen, for: .normal)
                button.setTitleColor(Color.systemGray3, for: .disabled)
                button.menu = createSessionTypeMenu()
                button.showsMenuAsPrimaryAction = true
                button.sizeToFit()
                cell.accessoryView = button
                if case .view = viewModel.mode {
                    button.isEnabled = false
                }
            case 1:
                cell.textLabel?.text = viewModel.type == .now ? "End Time" : "Start Time"
                cell.textLabel?.textColor = Color.systemBlackText
                if case .view = viewModel.mode {
                    let label = UILabel()
                    label.textColor = Color.systemGray3
                    label.font = .systemFont(ofSize: 17)
                    switch viewModel.type {
                    case .now: label.text = viewModel.formattedDateString(for: viewModel.endTime)
                    case .later: label.text = viewModel.formattedDateString(for: viewModel.startTime)
                    case .recurring: label.text = viewModel.formattedTimeString(for: viewModel.startTime)
                    default: break
                    }
                    label.sizeToFit()
                    cell.accessoryView = label
                } else {
                    let picker = UIDatePicker()
                    picker.tintColor = Color.primaryGreen
                    picker.tag = 0
                    picker.datePickerMode = viewModel.type == .recurring ? .time : .dateAndTime
                    picker.minimumDate = viewModel.type == .recurring ? .none : Date()
                    picker.date = viewModel.type == .now ? viewModel.endTime : viewModel.startTime
                    picker.timeZone = .current
                    picker.preferredDatePickerStyle = .compact
                    picker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged)
                    cell.accessoryView = picker
                }
            case 2:
                cell.textLabel?.text = "End Time"
                cell.textLabel?.textColor = Color.systemBlackText
                if case .view = viewModel.mode {
                    let label = UILabel()
                    label.textColor = Color.systemGray3
                    label.font = .systemFont(ofSize: 17)
                    switch viewModel.type {
                    case .later: label.text = viewModel.formattedDateString(for: viewModel.endTime)
                    case .recurring: label.text = viewModel.formattedTimeString(for: viewModel.endTime)
                    default: break
                    }
                    label.sizeToFit()
                    cell.accessoryView = label
                } else {
                    let picker = UIDatePicker()
                    picker.tintColor = Color.primaryGreen
                    picker.tag = 1
                    picker.datePickerMode = viewModel.type == .recurring ? .time : .dateAndTime
                    picker.minimumDate = viewModel.type == .recurring ? .none : Date()
                    picker.date = viewModel.endTime
                    picker.timeZone = .current
                    picker.preferredDatePickerStyle = .compact
                    picker.addTarget(self, action: #selector(timePickerChanged(_:)), for: .valueChanged)
                    cell.accessoryView = picker
                }
            case 3:
                cell.textLabel?.text = "Repeats"
                cell.textLabel?.textColor = Color.systemBlackText
                let accessoryLabel = UILabel()
                accessoryLabel.text = viewModel.descriptionForRecurringDays()
                accessoryLabel.textColor = Color.primaryGreen
                accessoryLabel.sizeToFit()
                cell.accessoryView = accessoryLabel
                if case .view = viewModel.mode {
                    accessoryLabel.textColor = Color.systemGray3
                }
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .view = viewModel.mode { return }
        if indexPath.section == 1 && indexPath.row ==  0 {
            viewModel.presentBlocklistSelection()
        }
        if indexPath.section == 2 && indexPath.row == 3 {
            viewModel.presentRecurringDaysSelection()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Blocklists"
        case 2: return "Session Configuration"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 0 {
            return 57
        }
        return 44
    }
}

extension SessionEditorRootView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
