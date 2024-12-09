//
//  ReviewManager.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/7/24.
//

import Foundation
import StoreKit

class ReviewManager {
    
    static let shared = ReviewManager()
        
    private init() {}
    
    func requestAppReviewIfAppropriate() {
        guard shouldRequestReview() else { return }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func incrementSessionCount() {
        var sessionCount = UserDefaults.standard.integer(forKey: "sessionCount")
        sessionCount += 1
        UserDefaults.standard.set(sessionCount, forKey: "sessionCount")
    }
    
    func recordFirstLaunchIfNeeded() {
        let firstLaunchDate = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date
        if firstLaunchDate == nil {
            UserDefaults.standard.set(Date(), forKey: "firstLaunchDate")
        }
    }
    
    private func isNewVersion() -> Bool {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let previousVersion = UserDefaults.standard.string(forKey: "appVersion")
        
        if currentVersion != previousVersion {
            UserDefaults.standard.set(currentVersion, forKey: "appVersion")
            return true
        }
        
        return false
    }
    
    private func shouldRequestReview() -> Bool {
        let sessionCount = UserDefaults.standard.integer(forKey: "sessionCount")
        let lastReviewRequestDate = UserDefaults.standard.object(forKey: "lastReviewRequestDate") as? Date ?? Date.distantPast
        let firstLaunchDate = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date ?? Date()
        
        let minimumSessionCount = 10
        let minimumDaysSinceFirstLaunch = 7
        let minimumDaysSinceLastRequest = 30
        
        guard sessionCount >= minimumSessionCount else { return false }
        
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        let firstReviewRequest = UserDefaults.standard.bool(forKey: "firstReviewRequest")
        
        if !firstReviewRequest {
            guard daysSinceFirstLaunch >= minimumDaysSinceFirstLaunch else { return false }
            UserDefaults.standard.set(true, forKey: "firstReviewRequest")
        } else {
            guard isNewVersion() else { return false }
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastReviewRequestDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minimumDaysSinceLastRequest else { return false }
        }

        UserDefaults.standard.set(Date(), forKey: "lastReviewRequestDate")
        
        return true
    }
}
