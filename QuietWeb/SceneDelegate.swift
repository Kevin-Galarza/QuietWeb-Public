//
//  SceneDelegate.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/6/24.
//

import UIKit
import UserNotifications
import RealmSwift

extension Notification.Name {
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    let injectionContainer = AppContainer()
    let dbMaintenanceManager = DBMaintenanceManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        UNUserNotificationCenter.current().delegate = self
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Color.primaryBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white

        let window = UIWindow(windowScene: windowScene)
        let mainVC = injectionContainer.makeMainViewController()

        window.rootViewController = mainVC
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        self.window = window

        ReviewManager.shared.recordFirstLaunchIfNeeded()
        
        defineNotificationCategories()

        if let response = connectionOptions.notificationResponse {
            let sessionManager = injectionContainer.sharedSessionManager
            handleNotificationResponse(response, sessionManager: sessionManager)
        }

        dbMaintenanceManager.performMaintenanceTasks()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle scene becoming active
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Handle scene resigning active
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Perform database maintenance tasks when entering foreground
        dbMaintenanceManager.performMaintenanceTasks()
        ContentBlockerManager.postStatus(identifier: ContentBlockerIdentifier.distractionBlockerIdentifier)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Handle scene entering background
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(name: .didReceivePushNotification, object: notification)
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let sessionManager = injectionContainer.sharedSessionManager
        handleNotificationResponse(response, sessionManager: sessionManager)
        completionHandler()
    }

    private func handleNotificationResponse(_ response: UNNotificationResponse, sessionManager: SessionManager) {
        let userInfo = response.notification.request.content.userInfo
        guard let sessionId = userInfo["sessionId"] as? String else {
            print("Error reading session ID associated with notification")
            return
        }

        switch response.actionIdentifier {
        case "START_ACTION":
            do {
                let sessionId = try ObjectId(string: sessionId)
                try sessionManager.startSession(sessionId)
            } catch {
                print(error)
            }
        case "END_ACTION":
            do {
                let sessionId = try ObjectId(string: sessionId)
                try sessionManager.endSession(sessionId)
                ReviewManager.shared.incrementSessionCount()
            } catch {
                print(error)
            }
        default:
            break
        }
    }

//    private func requestNotificationAuthorization() {
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Error requesting authorization: \(error)")
//                return
//            }
//            print(granted ? "Notification permission authorized" : "Notification permission denied")
//        }
//    }

    private func defineNotificationCategories() {
        let startAction = UNNotificationAction(identifier: "START_ACTION", title: "Start Session", options: [])
        let endAction = UNNotificationAction(identifier: "END_ACTION", title: "End Session", options: [])
        let startCategory = UNNotificationCategory(identifier: "START_CATEGORY", actions: [startAction], intentIdentifiers: [], options: [])
        let endCategory = UNNotificationCategory(identifier: "END_CATEGORY", actions: [endAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([startCategory, endCategory])
    }
}
