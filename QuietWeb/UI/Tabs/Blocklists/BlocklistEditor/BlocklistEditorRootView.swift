//
//  BlocklistEditorRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import UIKit
import Combine

class BlocklistEditorRootView: NiblessView {
    
    let viewModel: BlocklistEditorViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.setTitle("Save Blocklist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(Color.systemGray3, for: .disabled)
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(frame: CGRect = .zero, viewModel: BlocklistEditorViewModel) {
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
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "BlocklistEditorCell")
        
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
        viewModel.save()
        viewModel.dismiss()
    }
}

extension BlocklistEditorRootView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel.hostCount == 0 ? 1 : 2
        case 2:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlocklistEditorCell", for: indexPath)
        
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
            textField.placeholder = "Blocklist Name"
            textField.text = viewModel.name
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
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Add Websites"
                cell.textLabel?.textColor = Color.primaryGreen
                let accessoryImage = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
                let accessoryImageView = UIImageView(image: accessoryImage)
                accessoryImageView.tintColor = Color.primaryGreen
                cell.accessoryView = accessoryImageView
            } else {
                cell.textLabel?.text = "\(viewModel.selectedDistractionSourceIds.count) distraction sources"
                let accessoryLabel = UILabel()
                accessoryLabel.text = "Edit"
                accessoryLabel.textColor = Color.primaryGreen
                accessoryLabel.sizeToFit()
                cell.accessoryView = accessoryLabel
            }
        case 2:
            cell.textLabel?.text = "Enable Total Block"
            cell.textLabel?.textColor = Color.systemBlackText
            cell.detailTextLabel?.text = "Block all Safari web browsing"
            cell.detailTextLabel?.textColor = Color.systemGrayText
            let toggle = UISwitch(frame: .zero)
            toggle.isOn = viewModel.totalBlockEnabled
            toggle.addTarget(self, action: #selector(toggleSwitchChanged(_:)), for: .valueChanged)
            toggle.onTintColor = Color.primaryGreen
            cell.accessoryView = toggle
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            viewModel.presentWebsiteSelection()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Block Websites"
        case 2: return "Total Block"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 60
        }
        return 44
    }
    
    @objc private func nameChanged(_ textField: UITextField) {
        viewModel.name = textField.text ?? ""
    }
    
    @objc private func toggleSwitchChanged(_ toggleSwitch: UISwitch) {
        viewModel.totalBlockEnabled = toggleSwitch.isOn
    }
}

extension BlocklistEditorRootView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
