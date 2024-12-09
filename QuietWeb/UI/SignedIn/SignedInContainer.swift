//
//  SignedInContainer.swift
//  CirclePuzzle
//
//  Created by Kevin Galarza on 5/21/24.
//

import UIKit
import Combine
import AVKit
import AVFoundation

class SignedInContainer {
    
    // From parent container
    let sessionRepository: SessionRepository
    let blocklistRepository: BlocklistRepository
    let distractionGroupRepository: DistractionGroupRepository
    let sessionManager: SessionManager
    let notificationScheduler: NotificationScheduler
    let blocklistCoordinator: BlocklistCoordinator
//    let webShieldRepository: WebShieldRepository
    
    init(appContainer: AppContainer) {
        
        self.sessionRepository = appContainer.sharedSessionRepository
        self.blocklistRepository = appContainer.sharedBlocklistRepository
        self.distractionGroupRepository = appContainer.sharedDistractionGroupRepository
        self.sessionManager = appContainer.sharedSessionManager
        self.notificationScheduler = appContainer.sharedNotificationScheduler
        self.blocklistCoordinator = appContainer.sharedBlocklistCoordinator
//        self.webShieldRepository = appContainer.sharedWebShieldRepository
    }
    
    func makeSignedInViewController() -> SignedInViewController {
        let sessionsViewController = UINavigationController(rootViewController: makeSessionsController())
        let blocklistsViewController = UINavigationController(rootViewController: makeBlocklistsViewController(mode: .view, responder: nil))
//        let webShieldViewController = UINavigationController(rootViewController: makeWebShieldViewController())
        let settingsViewController = UINavigationController(rootViewController: makeSettingsViewController())
        
        let contentBlockerStatusFactory = { () -> ContentBlockerStatusViewController in
            return self.makeContentBlockerStatusViewController()
        }
        
        return SignedInViewController(sessionsViewController: sessionsViewController,
                                      blocklistsViewController: blocklistsViewController,
                                      settingsViewController: settingsViewController,
                                      contentBlockerStatusViewControllerFactory: contentBlockerStatusFactory)
    }
    
    // MARK: Sessions
    
    func makeSessionsController() -> SessionsViewController {
        let viewModel = makeSessionsViewModel()
        
        let sessionEditorFactory = { (mode: SessionEditorPresentationMode, responder: SessionEditorResponder) -> SessionEditorViewController in
            return self.makeSessionEditorViewController(mode: mode, responder: responder)
        }
        
        return SessionsViewController(viewModel: viewModel, sessionEditorViewControllerFactory: sessionEditorFactory)
    }
    
    func makeSessionsViewModel() -> SessionsViewModel {
        return SessionsViewModel(sessionRepository: sessionRepository, blocklistRepository: blocklistRepository, sessionManager: sessionManager, notificationScheduler: notificationScheduler)
    }
    
    // MARK: Session Editor
    
    func makeSessionEditorViewController(mode: SessionEditorPresentationMode, responder: SessionEditorResponder) -> SessionEditorViewController {
        let dependencyContainer = makeSessionEditorContainer(mode: mode)
        return dependencyContainer.makeSessionEditorViewController(responder: responder)
    }
    
    func makeSessionEditorContainer(mode: SessionEditorPresentationMode) -> SessionEditorContainer {
        let blocklistsFactory = { (mode: BlocklistsPresentationMode, responder: BlocklistSelectionResponder) -> BlocklistsViewController in
            return self.makeBlocklistsViewController(mode: mode, responder: responder)
        }
        
        return SessionEditorContainer(sessionRepository: sessionRepository, blocklistRepository: blocklistRepository, mode: mode, blocklistsViewControllerFactory: blocklistsFactory)
    }
    
    // MARK: Blocklists
    
    func makeBlocklistsViewController(mode: BlocklistsPresentationMode, responder: BlocklistSelectionResponder?) -> BlocklistsViewController {
        let viewModel = makeBlocklistsViewModel(mode: mode, responder: responder)
        
        let blocklistEditorFactory = { (mode: BlocklistEditorPresentationMode) in
            return self.makeBlocklistEditorViewController(mode: mode)
        }
        
        return BlocklistsViewController(viewModel: viewModel, blocklistEditorViewControllerFactory: blocklistEditorFactory)
    }
    
    func makeBlocklistsViewModel(mode: BlocklistsPresentationMode, responder: BlocklistSelectionResponder?) -> BlocklistsViewModel {
        return BlocklistsViewModel(blocklistRepository: blocklistRepository, sessionRepository: sessionRepository, distractionGroupRepository: distractionGroupRepository, mode: mode, responder: responder)
    }
    
    // MARK: Blocklist Editor
    
    func makeBlocklistEditorViewController(mode: BlocklistEditorPresentationMode) -> BlocklistEditorViewController {
        let dependencyContainer = makeBlocklistEditorContainer(mode: mode)
        return dependencyContainer.makeBlocklistEditorViewController()
    }
    
    func makeBlocklistEditorContainer(mode: BlocklistEditorPresentationMode) -> BlocklistEditorContainer {
        return BlocklistEditorContainer(distractionGroupRepository: distractionGroupRepository, blocklistRepository: blocklistRepository, mode: mode)
    }
    
    // MARK: Web Shield
    
//    func makeWebShieldViewController() -> WebShieldViewController {
//        let viewModel = makeWebShieldViewModel()
//        return WebShieldViewController(viewModel: viewModel)
//    }
//    
//    func makeWebShieldViewModel() -> WebShieldViewModel {
//        return WebShieldViewModel(webShieldRepository: webShieldRepository, blocklistCoordinator: blocklistCoordinator)
//    }
    
    // MARK: Settings
    
    func makeSettingsViewController() -> SettingsViewController {
        let viewModel = makeSettingsViewModel()
        return SettingsViewController(viewModel: viewModel)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel()
    }
    
    // MARK: Content Blocker Status
    
    func makeContentBlockerStatusViewController() -> ContentBlockerStatusViewController {
        let viewModel = makeContentBlockerStatusViewModel()
        
        let tutorialVideoFactory = { () -> AVPlayerViewController in
            return self.makeTutorialVideoViewController()
        }
        
        return ContentBlockerStatusViewController(viewModel: viewModel, tutorialVideoViewControllerFactory: tutorialVideoFactory)
    }
    
    func makeContentBlockerStatusViewModel() -> ContentBlockerStatusViewModel {
        return ContentBlockerStatusViewModel()
    }
    
    // MARK: Content Blocker Tutorial Video
    
    func makeTutorialVideoViewController() -> AVPlayerViewController {
        guard let url = URL(string: "") else { return AVPlayerViewController() }
        let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        return playerViewController
    }
}
