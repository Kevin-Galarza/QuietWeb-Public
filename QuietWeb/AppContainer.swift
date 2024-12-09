//
//  AppDepdencyContainer.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation

class AppContainer {
    
    let sharedSessionRepository: SessionRepository
    let sharedBlocklistRepository: BlocklistRepository
    let sharedDistractionGroupRepository: DistractionGroupRepository
    let sharedMainViewModel: MainViewModel
    let sharedSessionManager: SessionManager
    let sharedNotificationScheduler: NotificationScheduler
    let sharedBlocklistCoordinator: BlocklistCoordinator
//    let sharedWebShieldRepository: WebShieldRepository
    
    init() {
        let sessionRepository = makeSessionRepository()
        let blocklistRepository = makeBlocklistRepository()
        let distractionGroupRepository = makeDistractionGroupRepository()
//        let webShieldRepository = makeWebShieldRepository()
        let notificationScheduler = makeNotificationScheduler()
        let blocklistCoordinator = makeBlocklistCoordinator()
        
        func makeSessionRepository() -> SessionRepository {
            let dataStore = makeSessionDataStore()
            return SessionRepository(dataStore: dataStore)
        }
        
        func makeSessionDataStore() -> SessionDataStore {
            return RealmSessionDataStore()
//            return MockSessionDataStore()
        }
        
        func makeBlocklistRepository() -> BlocklistRepository {
            let dataStore = makeBlocklistDataStore()
            return BlocklistRepository(dataStore: dataStore)
        }
        
        func makeBlocklistDataStore() -> BlocklistDataStore {
            return RealmBlocklistDataStore()
//            return MockBlocklistDataStore()
        }
        
        func makeDistractionGroupRepository() -> DistractionGroupRepository {
            let dataStore = makeDistractionGroupDataStore()
            return DistractionGroupRepository(dataStore: dataStore)
        }
        
        func makeDistractionGroupDataStore() -> DistractionGroupDataStore {
            return JsonDistractionGroupDataStore()
        }
        
//        func makeWebShieldRepository() -> WebShieldRepository {
//            let dataStore = makeWebShieldDataStore()
//            return WebShieldRepository(dataStore: dataStore)
//        }
//        
//        func makeWebShieldDataStore() -> WebShieldDataStore {
//            return RealmWebShieldDataStore()
////            return MockWebShieldDataStore()
//        }
        
        func makeMainViewModel() -> MainViewModel {
            return MainViewModel()
        }
        
        func makeSessionManager() -> SessionManager {
            return SessionManager(sessionRepository: sessionRepository, notificationScheduler: notificationScheduler, blocklistCoordinator: blocklistCoordinator)
        }
        
        func makeNotificationScheduler() -> NotificationScheduler {
            return NotificationScheduler()
        }
        
        func makeBlocklistCoordinator() -> BlocklistCoordinator {
            let contentBlockerManager = makeContentBlockerManger()
            return BlocklistCoordinator(sessionRepository: sessionRepository, blocklistRepository: blocklistRepository, distractionGroupRepository: distractionGroupRepository, contentBlockerManager: contentBlockerManager)
        }
        
        func makeContentBlockerManger() -> ContentBlockerManager {
            return ContentBlockerManager()
        }

        self.sharedSessionRepository = sessionRepository
        self.sharedBlocklistRepository = blocklistRepository
        self.sharedDistractionGroupRepository = distractionGroupRepository
        self.sharedMainViewModel = makeMainViewModel()
        self.sharedSessionManager = makeSessionManager()
        self.sharedNotificationScheduler = notificationScheduler
        self.sharedBlocklistCoordinator = blocklistCoordinator
//        self.sharedWebShieldRepository = webShieldRepository
    }

    // MARK: Main
    
    func makeMainViewController() -> MainViewController {
        let launchViewController = makeLaunchViewController()

        let onboardingViewControllerFactory = {
          return self.makeOnboardingViewController()
        }
        
        let signedInViewControllerFactory = {
          return self.makeSignedInViewController()
        }

        return MainViewController(viewModel: self.sharedMainViewModel,
                                  launchViewController: launchViewController,
                                  onboardingViewControllerFactory: onboardingViewControllerFactory,
                                  signedInViewControllerFactory: signedInViewControllerFactory)
    }
    
    // MARK: Launching
    
    func makeLaunchViewController() -> LaunchViewController {
        return LaunchViewController(launchViewModelFactory: self)
    }
    
    func makeLaunchViewModel() -> LaunchViewModel {
        return LaunchViewModel(notSignedInResponder: sharedMainViewModel, signedInResponder: sharedMainViewModel, blocklistCoordinator: sharedBlocklistCoordinator)
    }
    
    // MARK: Onboarding
    
    func makeOnboardingViewController() -> OnboardingViewController {
        let onboardingContainer = OnboardingContainer(appContainer: self)
        return onboardingContainer.makeOnboardingViewController()
    }
    
    // MARK: Signed-in

    func makeSignedInViewController() -> SignedInViewController {
        let dependencyContainer = makeSignedInContainer()
        return dependencyContainer.makeSignedInViewController()
    }

    func makeSignedInContainer() -> SignedInContainer  {
        return SignedInContainer(appContainer: self)
    }
}

extension AppContainer: LaunchViewModelFactory {}
