//
//  BlocklistsRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine

class BlocklistsRootView: NiblessView {
    
    let viewModel: BlocklistsViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    private let tableView = UITableView()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 0 // Allow multiple lines
        label.isHidden = true
        
        // Create the attributed string with different styles
        let fullText = NSMutableAttributedString()
        
        // First Line: Bold
        let firstLine = NSAttributedString(
            string: "No Blocklists Available\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.darkGray
            ]
        )
        
        // Second Line: Regular
        let secondLinePart1 = NSAttributedString(
            string: "Tap ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.lightGray
            ]
        )
        
        // "+" Character: Custom Color
        let plusCharacter = NSAttributedString(
            string: "+",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: Color.primaryBlue
            ]
        )
        
        // Second Line continued: Regular
        let secondLinePart2 = NSAttributedString(
            string: " to add a new blocklist.",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.lightGray
            ]
        )
        
        // Combine the parts into the full attributed string
        fullText.append(firstLine)
        fullText.append(secondLinePart1)
        fullText.append(plusCharacter)
        fullText.append(secondLinePart2)
        
        label.attributedText = fullText
        
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.setTitle("Save Blocklists", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(Color.systemGray3, for: .disabled)
        button.layer.cornerRadius = 12
        return button
    }()
    
    init(frame: CGRect = .zero, viewModel: BlocklistsViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
        setupBindings()
    }
    
    @objc private func saveButtonTapped() {
        viewModel.save()
    }
    
    private func applyStyle() {
        backgroundColor = Color.primaryBackground
        tableView.backgroundColor = Color.primaryBackground
        if viewModel.mode != .view {
            messageLabel.attributedText = nil
            messageLabel.text = "No Blocklists Available"
        }
    }
    
    private func constructHierarchy() {
        addSubview(tableView)
        addSubview(messageLabel)
        if viewModel.mode != .view {
            addSubview(saveButton)
        }
    }
    
    private func applyConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if viewModel.mode != .view {
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                saveButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
                saveButton.heightAnchor.constraint(equalToConstant: 50),
                saveButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                saveButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
        }
    }
    
    private func setupBindings() {
        if viewModel.mode != .view {
            viewModel.savingIsEnabledPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isEnabled in
                    self?.saveButton.setEnabled(isEnabled)
                }
                .store(in: &subscriptions)
        }
        
        viewModel.$blocklists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blocklists in
                self?.tableView.reloadData()
                self?.messageLabel.isHidden = !blocklists.isEmpty
            }
            .store(in: &subscriptions)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BlocklistTableViewCell.self, forCellReuseIdentifier: "BlocklistCell")
    }
}

extension BlocklistsRootView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.blocklists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlocklistCell", for: indexPath) as! BlocklistTableViewCell
        let blocklist = viewModel.blocklists[indexPath.row]
        
        cell.accessoryType = .none
        cell.accessoryView = nil
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        cell.textLabel?.text = blocklist.name
        cell.detailTextLabel?.text = viewModel.blocklistDescription(blocklist: blocklist)
        
        switch viewModel.mode {
        case .view:
            let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
            let accessoryView = UIImageView(image: image)
            accessoryView.tintColor = Color.primaryGreen
            cell.accessoryView = accessoryView
            cell.selectionAccessoryView.isHidden = true
        case .select:
            cell.accessoryType = .none
            cell.selectionAccessoryView.isHidden = false
            cell.setSelectionState(isSelected: viewModel.isSelected(blocklist: blocklist))
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blocklist = viewModel.blocklists[indexPath.row]
        if case .view = viewModel.mode {
            viewModel.editBlocklist(blocklist)
        }
        if case .select = viewModel.mode {
            viewModel.toggleSelection(for: blocklist)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .view = viewModel.mode {
            return true
        }
        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let blocklist = viewModel.blocklists[indexPath.row]
            viewModel.confirmDeleteBlocklist(blocklist: blocklist)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
