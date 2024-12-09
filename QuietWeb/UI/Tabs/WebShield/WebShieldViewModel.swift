//
//  WebShieldViewModel.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import Foundation

class WebShieldViewModel {
    
    let webShieldRepository: WebShieldRepository
    let blocklistCoordinator: BlocklistCoordinator
    
    var adsBlocklistIsEnabled = false
    var privacyBlocklistIsEnabled = false
    var securityBlocklistIsEnabled = false
    
    init(webShieldRepository: WebShieldRepository, blocklistCoordinator: BlocklistCoordinator) {
        self.webShieldRepository = webShieldRepository
        self.blocklistCoordinator = blocklistCoordinator
        loadBlocklistStates()
    }
    
    func loadBlocklistStates() {
        do {
            guard let webShield = try webShieldRepository.read().first else { return }
            adsBlocklistIsEnabled = webShield.enabledWebShieldGroups.contains(.ads)
            privacyBlocklistIsEnabled = webShield.enabledWebShieldGroups.contains(.privacy)
            securityBlocklistIsEnabled = webShield.enabledWebShieldGroups.contains(.security)
        } catch {
            print("error loading blocklist states for web shield: \(error)")
        }
    }
    
    // TODO: have to verify performance when updating blockers multiple times in a small time window
    func toggleBlocklist(group: WebShieldGroup) {
        switch group {
        case .ads: adsBlocklistIsEnabled.toggle()
        case .privacy: privacyBlocklistIsEnabled.toggle()
        case .security: securityBlocklistIsEnabled.toggle()
        }
        save()
//        blocklistCoordinator.handleBlocklistUpdate(for: .webShield(group))
    }
    
    func save() {
        do {
            guard let webShield = try webShieldRepository.read().first else { return }
            var enabledWebShieldGroups: [WebShieldGroup] = []
            if adsBlocklistIsEnabled { enabledWebShieldGroups.append(.ads) }
            if privacyBlocklistIsEnabled { enabledWebShieldGroups.append(.privacy) }
            if securityBlocklistIsEnabled { enabledWebShieldGroups.append(.security) }
            try webShieldRepository.update(webShield: webShield, enabledWebShieldGroups: enabledWebShieldGroups)
        } catch {
            print("error saving web shield blocklist state: \(error)")
        }
    }
    
    // MARK: Helper Methods
    
    func groupState(for indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        case 0: return adsBlocklistIsEnabled
        case 1: return privacyBlocklistIsEnabled
        case 2: return securityBlocklistIsEnabled
        default: return false
        }
    }
    
    func group(for indexPath: IndexPath) -> WebShieldGroup? {
        switch indexPath.row {
        case 0: return .ads
        case 1: return .privacy
        case 2: return .security
        default: return nil
        }
    }
}
