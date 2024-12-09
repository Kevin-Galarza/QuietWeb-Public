//
//  BlocklistCoordinator.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/7/24.
//

import Foundation
import RealmSwift

enum BlockingMode {
    case distractions
//    case webShield(WebShieldGroup)
}

class BlocklistCoordinator {
    
    let sessionRepository: SessionRepository
    let blocklistRepository: BlocklistRepository
    let distractionGroupRepository: DistractionGroupRepository
//    let webShieldRepository: WebShieldRepository
    let contentBlockerManager: ContentBlockerManager
    
    init(sessionRepository: SessionRepository, blocklistRepository: BlocklistRepository, distractionGroupRepository: DistractionGroupRepository, contentBlockerManager: ContentBlockerManager) {
        self.sessionRepository = sessionRepository
        self.blocklistRepository = blocklistRepository
        self.distractionGroupRepository = distractionGroupRepository
//        self.webShieldRepository = webShieldRepository
        self.contentBlockerManager = contentBlockerManager
    }
    
    func handleBlocklistUpdate(for mode: BlockingMode) {
        do {
            let rules: [[String : Any]]?
            switch mode {
            case .distractions:
                if try shouldApplyTotalBlock() {
                    rules = contentBlockerManager.generateTotalBlockRule()
                } else {
                    let urls = try compileDistractionBlocklist()
                    rules = contentBlockerManager.generateContentBlockerRules(from: urls)
                }
                contentBlockerManager.updateMasterBlocklist(fileName: .distractionBlockerFileName, 
                                                            rules: rules ?? [["trigger": ["url-filter": ".*", "if-domain": ["domain.com"]], "action": ["type": "ignore-previous-rules"]]])
                contentBlockerManager.refreshContentBlocker(identifier: .distractionBlockerIdentifier)
//            case .webShield(let webShieldGroup):
//                rules = try compileWebShieldRules(for: webShieldGroup)
//                contentBlockerManager.updateMasterBlocklist(fileName: webShieldGroup.contentBlockerMasterFileName,
//                                                            rules: rules ?? [["trigger": ["url-filter": ".*", "if-domain": ["domain.com"]], "action": ["type": "ignore-previous-rules"]]]
//)
//                contentBlockerManager.refreshContentBlocker(identifier: webShieldGroup.contentBlockerIdentifier)
            }
        } catch {
            print("Error handling blocklist update, \(error)")
        }
    }
    
    private func shouldApplyTotalBlock() throws -> Bool {
        let activeSessions = try sessionRepository.readAll().filter { $0.isActive }
        for session in activeSessions {
            for id in session.blocklists {
                let blocklist = try blocklistRepository.read(id: id)
                if blocklist?.totalBlockEnabled == true { return true }
            }
        }
        return false
    }
    
    // TODO: adjust this to call on distraction group service and combine hosts with user distractions
    private func compileDistractionBlocklist() throws -> Set<String> {
        do {
            let activeSessions = try sessionRepository.readAll().filter { $0.isActive }
            var hosts = Set<String>()
            for session in activeSessions {
                for id in session.blocklists {
                    let blocklist = try blocklistRepository.read(id: id)
                    let selectedGroups = blocklist?.distractionGroups ?? List<DistractionGroup>()
                    let selectedSourceIds = blocklist?.distractionSourceIds ?? List<String>()
                    hosts.formUnion(getHostsForSelectedSources(selectedGroups, selectedSourceIds))
                    hosts.formUnion(blocklist?.userDistractions ?? List<String>())
                }
            }
            return hosts
        } catch {
            print("Failed to resolve blocklist: \(error)")
            throw(error)
        }
    }
    
    private func getHostsForSelectedSources(_ groups: List<DistractionGroup>, _ sourceIds: List<String>) -> [String] {
        var hosts: [String] = []
        
        for group in groups {
            // Fetch the sources for the current group
            if let sources = distractionGroupRepository.distractionData[group] {
                // Filter sources based on whether their id is in the sourceIds list
                let filteredHosts = sources
                    .filter { sourceIds.contains($0.id) } // Only include sources with an id in sourceIds
                    .flatMap { $0.hosts } // Flatten the array of hosts
                
                hosts.append(contentsOf: filteredHosts)
            }
        }
        
        return hosts
    }
    
//    private func compileWebShieldRules(for group: WebShieldGroup) throws -> [[String: Any]]? {
//        guard let webShield = try webShieldRepository.read().first else { return nil }
//
//        var enabledWebShieldBlocklists: [WebShieldBlocklist] = []
//        
//        guard webShield.enabledWebShieldGroups.contains(group) else { return nil }
//        
//        enabledWebShieldBlocklists.append(contentsOf: webShield.enabledWebShieldBlocklists.filter { group.associatedBlocklists.contains($0) })
//
//        guard !enabledWebShieldBlocklists.isEmpty else { return nil }
//        
//        var combinedRules: [[String: Any]] = []
//        
//        try enabledWebShieldBlocklists.forEach { blocklist in
//            try blocklist.fileNames.forEach { fileName in
//                guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json"),
//                      let data = try? Data(contentsOf: fileURL) else {
//                    throw NSError(domain: "WebShield", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(fileName)"])
//                }
//
//                if let rules = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
//                    combinedRules.append(contentsOf: rules)
//                    print("\(group) rule count: \(combinedRules.count)")
//                } else {
//                    throw NSError(domain: "WebShield", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format in file: \(fileName)"])
//                }
//            }
//        }
//        
//        return combinedRules
//    }
}
