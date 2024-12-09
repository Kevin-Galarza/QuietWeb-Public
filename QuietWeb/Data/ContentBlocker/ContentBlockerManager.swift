//
//  ContentBlockerManager.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/5/24.
//

import Foundation
import SafariServices

enum ContentBlockerIdentifier: String {
    case distractionBlockerIdentifier = "com.galarza.QuietWeb.QuietWebDistractionBlocker"
    case adsBlockerIdentifier = "com.galarza.QuietWeb.QuietWebAdsBlocker"
    case privacyBlockerIdentifier = "com.galarza.QuietWeb.QuietWebPrivacyBlocker"
    case securityBlockerIdentifier = "com.galarza.QuietWeb.QuietWebSecurityBlocker"
}

enum ContentBlockerMasterFileName: String {
    case distractionBlockerFileName = "masterDistractionsBlocklist.json"
    case adsBlockerFileName = "masterAdsBlocklist.json"
    case privacyBlockerFileName = "masterPrivacyBlocklist.json"
    case securityBlockerFileName = "masterSecurityBlocklist.json"
}
extension Notification.Name {
    static let contentBlockerDidBecomeEnabled = Notification.Name("contentBlockerDidBecomeEnabled")
    static let contentBlockerDidBecomeDisabled = Notification.Name("contentBlockerDidBecomeDisabled")
}

class ContentBlockerManager {
    // shared group
    private let appGroupID = "group.com.galarza.QuietWeb"
    
    class func postStatus(identifier: ContentBlockerIdentifier) {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: identifier.rawValue) { state, error in
            if let error = error {
                print("Error checking content blocker status: \(error.localizedDescription)")
                return
            }

            if let state = state {
                if state.isEnabled {
                    NotificationCenter.default.post(name: .contentBlockerDidBecomeEnabled, object: nil)
                    print("Content blocker is enabled.")
                } else {
                    NotificationCenter.default.post(name: .contentBlockerDidBecomeDisabled, object: nil)
                    print("Content blocker is disabled.")
                }
            }
        }
    }
        
    func refreshContentBlocker(identifier: ContentBlockerIdentifier) {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: identifier.rawValue) { error in
            if let error = error {
                print("Failed to refresh content blocker: \(error.localizedDescription)")
            } else {
                print("Content blocker refreshed successfully. ID: \(identifier)")
            }
        }
    }
    
    func generateTotalBlockRule() -> [[String: Any]] {
        let rule: [String: Any] = [
            "trigger": [
                "url-filter": ".*",
                "url-filter-is-case-sensitive": false
            ],
            "action": [
                "type": "block"
            ]
        ]
        return [rule]
    }
    
    func generateContentBlockerRules(from urls: Set<String>) -> [[String : Any]]? {
        guard !urls.isEmpty else {
            return nil
        }
        return urls.map { url in
            let regex = createRegex(for: url)
            return ["trigger": ["url-filter": regex], "action": ["type": "block"]]
        }
    }
    
    func updateMasterBlocklist(fileName: ContentBlockerMasterFileName, rules: [[String : Any]]) {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.appendingPathComponent(fileName.rawValue) else {
            print("Failed to get container URL for app group.")
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: rules, options: [])
            try data.write(to: url, options: .atomic)
            print("Master blocklist updated successfully.")
        } catch {
            print("Failed to update master blocklist: \(error)")
        }
        
        do {
            // Get the file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            // Get the file size in bytes
            if let fileSize = attributes[.size] as? NSNumber {
                print("File size: \(fileSize.intValue) bytes")
            }
        } catch {
            print("Failed to get file attributes: \(error.localizedDescription)")
        }
    }

    private func createRegex(for url: String) -> String {
        var domainAndPath = url.replacingOccurrences(of: "http://", with: "")
        domainAndPath = domainAndPath.replacingOccurrences(of: "https://", with: "")
        
        // Extract domain and path
        let components = domainAndPath.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        let domain = String(components.first ?? "")
        let path = components.count > 1 ? String(components[1]) : ""
        
        // Escape domain for regex
        let escapedDomain = NSRegularExpression.escapedPattern(for: domain)
        
        // Build regex for domain and path
        if path.isEmpty {
            // General match for all paths
            return ".*://(www\\.)?(.+\\.)?\(escapedDomain)/.*"
        } else {
            // Specific match for the given path
            let escapedPath = NSRegularExpression.escapedPattern(for: path)
            return ".*://(www\\.)?(.+\\.)?\(escapedDomain)/\(escapedPath)"
        }
    }
}
