//
//  SettingsViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import Foundation
import Combine

struct SettingItem {
    let title: String
    let type: SettingType
}

enum SettingType {
    case toggle(Bool) // For "Allow Notifications"
    case drillIn // For "About", "Help Center"
    case link // For "Leave a Review", "Privacy Policy", "Terms of Service"
}

class SettingsViewModel: ObservableObject {
    @Published var allowNotifications: Bool {
        didSet {
            UserDefaults.standard.set(allowNotifications, forKey: "allowNotifications")
            updateSettingsSections()
        }
    }
    @Published var settingsSections: [[SettingItem]] = []
    
    let presentURLInternal = PassthroughSubject<URL, Never>()
    let presentURLExternal = PassthroughSubject<URL, Never>()
    
    init() {
        if UserDefaults.standard.object(forKey: "allowNotifications") == nil {
            self.allowNotifications = true
            UserDefaults.standard.set(true, forKey: "allowNotifications")
        } else {
            self.allowNotifications = UserDefaults.standard.bool(forKey: "allowNotifications")
        }
        updateSettingsSections()
    }
    
    func handleAbout() {
        guard let url = URL(string: "https://google.com") else {
            fatalError("Expected a valid URL")
        }
        presentURLInternal.send(url)
    }
    
    func handleHelpCenter() {
        guard let url = URL(string: "https://youtube.com") else {
            fatalError("Expected a valid URL")
        }
        presentURLInternal.send(url)
    }
    
    func handleAppReview() {
        // Replace the placeholder value below with the App Store ID for your app.
        // You can find the App Store ID in your app's product URL.
        let appStoreID = "1234567890" // Replace this with your actual App Store ID
        let url = "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        
        guard let url = URL(string: url) else {
            fatalError("Expected a valid URL")
        }
        presentURLExternal.send(url)
    }
    
    func handlePrivacyPolicy() {
        guard let url = URL(string: "https://x.com") else {
            fatalError("Expected a valid URL")
        }
        presentURLExternal.send(url)
    }
    
    func handleTerms() {
        guard let url = URL(string: "https://meta.com") else {
            fatalError("Expected a valid URL")
        }
        presentURLExternal.send(url)
    }
    
    private func updateSettingsSections() {
        settingsSections = [
            [
                SettingItem(title: "About", type: .drillIn),
                SettingItem(title: "Help Center", type: .drillIn),
                SettingItem(title: "Leave a Review", type: .link)
            ],
            [
                SettingItem(title: "Privacy Policy", type: .link),
                SettingItem(title: "Terms of Service", type: .link)
            ]
        ]
    }
}
