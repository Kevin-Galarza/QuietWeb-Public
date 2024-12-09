//
//  SessionsViewController.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import UIKit
import Combine
import RealmSwift
import UserNotifications

class SessionsViewController: NiblessViewController {
    
    let viewModel: SessionsViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    let haptics = UIImpactFeedbackGenerator(style: .medium)
    
    // child view controller
    var sessionEditorViewController: SessionEditorViewController?
    
    // factory
    let makeSessionEditorViewController: (SessionEditorPresentationMode, SessionEditorResponder) -> SessionEditorViewController
    
    init(viewModel: SessionsViewModel, sessionEditorViewControllerFactory: @escaping (SessionEditorPresentationMode, SessionEditorResponder) -> SessionEditorViewController) {
        self.viewModel = viewModel
        self.makeSessionEditorViewController = sessionEditorViewControllerFactory
        super.init()
        setupBindings()
        setupNavigationBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        haptics.prepare()
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePushNotification(_:)), name: .didReceivePushNotification, object: nil)
        ReviewManager.shared.requestAppReviewIfAppropriate()
    }
    
    override func loadView() {
        view = SessionsRootView(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    private func setupBindings() {
        viewModel.presentSessionEditorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mode in
                self?.presentSessionEditorViewController(mode: mode)
            }
            .store(in: &subscriptions)
        
        viewModel.startSessionErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                if session.endTime < Date() {
                    self?.presentStartSessionErrorAlertEndTime(session: session)
                } else {
                    self?.presentStartSessionErrorAlertBlocklists(session: session)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.confirmDeleteSessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.presentConfirmDeleteSessionAlert(session: session)
            }
            .store(in: &subscriptions)
        
        viewModel.hapticPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.haptics.impactOccurred()
            }
            .store(in: &subscriptions)
    }
    
    private func setupNavigationBar() {
        title = "Sessions"
        let image = UIImage(systemName: "plus.circle.fill")
        let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        rightButton.tintColor = .white
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.backButtonTitle = "Back"
    }
    
    func presentSessionEditorViewController(mode: SessionEditorPresentationMode) {
        if let _ = sessionEditorViewController {
            sessionEditorViewController = nil
        }
        requestNotificationAuthorizationInfo { [weak self] shouldDisplay in
            if shouldDisplay {
                DispatchQueue.main.async {
                    self?.presentNotificationAuthorizationRequest()
                }
            }
        }
        let sessionEditorViewControllerToPresent = makeSessionEditorViewController(mode, viewModel)
        sessionEditorViewController = sessionEditorViewControllerToPresent
        navigationController?.pushViewController(sessionEditorViewControllerToPresent, animated: true)
    }
    
    func presentNotificationAuthorizationRequest() {
        let alertController = UIAlertController(title: "Enhance Your Experience", message: "Notifications help you manage session reminders and start/end sessions quickly without opening the app. We recommend allowing notifications.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.requestNotificationAuthorization()
        }
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    func presentStartSessionErrorAlertBlocklists(session: Session) {
        let alertController = UIAlertController(title: "Cannot Begin Session", message: "Session does not have a blocklist.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.viewModel.editSession(session)
        }
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    func presentStartSessionErrorAlertEndTime(session: Session) {
        let alertController = UIAlertController(title: "Cannot Begin Session", message: "Session has expired.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard session.type != .recurring else {
                self?.viewModel.refresh()
                return
            }
            self?.viewModel.deleteSession(sessionId: session._id)
        }
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    func presentConfirmDeleteSessionAlert(session: Session) {
        let alertController = UIAlertController(title: "Delete Session", message: "Are you sure you want to permanently delete \(session.name)?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteSession(sessionId: session._id)
            self?.haptics.impactOccurred()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        alertController.view.tintColor = Color.primaryGreen
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func addButtonTapped() {
        viewModel.addSession()
    }
    
    @objc private func appDidBecomeActive() {
        viewModel.refresh()
    }
    
    @objc private func didReceivePushNotification(_ notification: Notification) {
        viewModel.refresh()
    }
}

extension SessionsViewController {
    private func requestNotificationAuthorizationInfo(completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    private func requestNotificationAuthorization() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
                return
            }
            print(granted ? "Notification permission authorized" : "Notification permission denied")
        }
    }
}
