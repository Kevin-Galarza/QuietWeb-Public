//
//  SessionsRootView.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine
import RealmSwift

class SessionsRootView: NiblessView {
    
    let viewModel: SessionsViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.sizeToFit()
        label.textColor = Color.systemBlackText
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow multiple lines
        label.isHidden = true
        
        // Create the attributed string with different styles
        let fullText = NSMutableAttributedString()
        
        // First Line: Bold
        let firstLine = NSAttributedString(
            string: "No Sessions Scheduled\n",
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
            string: " to schedule a session.",
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
    
    init(frame: CGRect = .zero, viewModel: SessionsViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        applyStyle()
        constructHierarchy()
        applyConstraints()
        setupBindings()
        setupRefreshControl()
    }
    
    private func applyStyle() {
        backgroundColor = Color.primaryBackground
        tableView.backgroundColor = Color.primaryBackground
    }
    
    private func constructHierarchy() {
        addSubview(greetingLabel)
        addSubview(tableView)
        addSubview(messageLabel)
    }
    
    private func applyConstraints() {
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            greetingLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SessionCell")
        
        viewModel.$greeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] greeting in
                self?.greetingLabel.text = greeting
            }
            .store(in: &subscriptions)
        
        viewModel.refreshTableViewPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        viewModel.$sessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.messageLabel.isHidden = !sessions.isEmpty
            }
            .store(in: &subscriptions)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
    }

    @objc private func refreshTableView(_ sender: UIRefreshControl) {
        viewModel.refresh()
        refreshControl.endRefreshing()
    }
    
    @objc func cellStartSessionButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let sessionId = viewModel.categorizedSessions.filter { $0.sessionSection == .pending }[index].sessionId
        viewModel.startSession(sessionId)
    }

    @objc func cellEndSessionButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let sessionId = viewModel.categorizedSessions.filter { $0.sessionSection == .active }[index].sessionId
        viewModel.endSession(sessionId)
    }
}

extension SessionsRootView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = viewModel.availableSections.count
        tableView.refreshControl = sectionCount > 0 ? refreshControl : nil
        return sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sessionSection = viewModel.availableSections[section]
        return viewModel.categorizedSessions.filter { $0.sessionSection == sessionSection }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sessionSection = viewModel.availableSections[indexPath.section]
        let sessionId = viewModel.categorizedSessions.filter { $0.sessionSection == sessionSection }[indexPath.row].sessionId
        guard let session = viewModel.sessions.first(where: { $0._id == sessionId }) else { return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SubtitleTableViewCell
        
        cell.accessoryView = nil
        cell.textLabel?.text = ""
        cell.accessoryType = .none
        cell.detailTextLabel?.text = ""
        
        switch sessionSection {
        case .active:
            cell.configure(withTitle: session.name, subtitle: "Active", subtitleColor: Color.primaryGreen)
            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
            if viewModel.sessionIsReadyToExpire(session) {
                let button = UIButton()
                let attributedTitle = NSAttributedString(string: "Stop Blocking", attributes: [.font : UIFont.boldSystemFont(ofSize: 15)])
                button.setAttributedTitle(attributedTitle, for: .normal)
                button.setTitleColor(Color.primaryGreen, for: .normal)
                button.backgroundColor = Color.primaryGreen.withAlphaComponent(0.2)
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
                button.layer.cornerRadius = 16
                button.sizeToFit()
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(cellEndSessionButtonTapped(_:)), for: .touchUpInside)
                cell.accessoryView = button
            } else {
                let label = UILabel()
                label.textColor = .gray
                label.font = .boldSystemFont(ofSize: 17)
                label.text = viewModel.remainingTime(session)
                label.sizeToFit()
                cell.accessoryView = label
            }
        case .pending:
            cell.configure(withTitle: session.name, subtitle: "Pending", subtitleColor: Color.primaryYellow)
            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
            let button = UIButton()
            let attributedTitle = NSAttributedString(string: "Start Blocking", attributes: [.font : UIFont.boldSystemFont(ofSize: 15)])
            button.setAttributedTitle(attributedTitle, for: .normal)
            button.setTitleColor(Color.primaryYellow, for: .normal)
            button.backgroundColor = Color.primaryYellow.withAlphaComponent(0.2)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            button.layer.cornerRadius = 16
            button.sizeToFit()
            button.tag = indexPath.row
            button.addTarget(self, action: #selector(cellStartSessionButtonTapped(_:)), for: .touchUpInside)
            cell.accessoryView = button
        case .upcoming:
            let subtitle = viewModel.formattedUpcomingSubtitle(for: session)
            cell.configure(withTitle: session.name, subtitle: subtitle, subtitleColor: .gray)
            cell.configureDisclosureAccessory()
        case .recurring:
            let subtitle = viewModel.formattedRecurringSubtitle(for: session)
            cell.configure(withTitle: session.name, subtitle: subtitle, subtitleColor: .gray)
            cell.configureDisclosureAccessory()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sessionSection = viewModel.availableSections[section]
        switch sessionSection {
        case .active:
            return "Active Sessions"
        case .pending:
            return "Pending Sessions"
        case .upcoming:
            return "Upcoming Sessions"
        case .recurring:
            return "Recurring Sessions"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sessionSection = viewModel.availableSections[indexPath.section]
        let sessionId = viewModel.categorizedSessions.filter { $0.sessionSection == sessionSection }[indexPath.row].sessionId
        
        guard let session = viewModel.sessions.first(where: { $0._id == sessionId }) else { return }
        
        if sessionSection == .active {
            viewModel.viewSession(session)
        }

        if sessionSection == .pending || sessionSection == .upcoming || sessionSection == .recurring {
            viewModel.editSession(session)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let sessionSection = viewModel.availableSections[indexPath.section]
        if sessionSection == .upcoming || sessionSection == .recurring || sessionSection == .pending {
            return .delete
        } else {
            return .none
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sessionSection = viewModel.availableSections[indexPath.section]
            let sessionId = viewModel.categorizedSessions.filter { $0.sessionSection == sessionSection }[indexPath.row].sessionId
            viewModel.confirmDeleteSession(sessionId: sessionId)
        }
    }
}
