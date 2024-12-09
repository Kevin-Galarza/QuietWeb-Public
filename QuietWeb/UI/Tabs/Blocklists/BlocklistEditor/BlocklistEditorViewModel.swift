//
//  BlocklistEditorViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import Foundation
import Combine
import RealmSwift

class BlocklistEditorViewModel: DistractionSelectionDataProvider {
    
    let blocklistRepository: BlocklistRepository
    let distractionGroupRepository: DistractionGroupRepository
    let blocklist: Blocklist
    let mode: BlocklistEditorPresentationMode
    
    var hostCount: Int {
        return selectedUserDistractions.count + distractionGroupRepository.calculateHostCount(for: selectedDistractionGroups, and: selectedDistractionSourceIds)
    }

    var name: String = "" {
        didSet {
            resolveSavingIsEnabled()
        }
    }
    var selectedUserDistractions: Set<String> = [] {
        didSet {
            resolveSavingIsEnabled()
        }
    }
    var selectedDistractionGroups: Set<DistractionGroup> = [] {
        didSet {
            resolveSavingIsEnabled()
        }
    }
    var selectedDistractionSourceIds: Set<String> = []
    var totalBlockEnabled: Bool = false {
        didSet {
            refresh()
        }
    }
    var savingIsEnabled = false {
        willSet {
            savingIsEnabledPublisher.send(newValue)
        }
    }
    
    let savingIsEnabledPublisher = PassthroughSubject<Bool, Never>()
    let dismissBlocklistEditorPublisher = PassthroughSubject<Void, Never>()
    let presentWebsiteSelectionPublisher = PassthroughSubject<Void, Never>()
    let refreshTableViewPublisher = PassthroughSubject<Void, Never>()
    
    init(blocklistRepository: BlocklistRepository, distractionGroupRepository: DistractionGroupRepository, mode: BlocklistEditorPresentationMode) {
        self.blocklistRepository = blocklistRepository
        self.distractionGroupRepository = distractionGroupRepository
        self.mode = mode
        
        switch mode {
        case .create:
            self.blocklist = Blocklist()
        case .edit(let blocklist):
            self.blocklist = blocklist
            self.name = blocklist.name
            self.selectedUserDistractions = Set(blocklist.userDistractions.map { $0 })
            self.selectedDistractionGroups = Set(blocklist.distractionGroups.map { $0 })
            self.selectedDistractionSourceIds = Set(blocklist.distractionSourceIds.map { $0 })
            self.totalBlockEnabled = blocklist.totalBlockEnabled
        }
    }
    
    func resolveSavingIsEnabled() {
        if !name.isEmpty && (!selectedDistractionGroups.isEmpty || !selectedUserDistractions.isEmpty || totalBlockEnabled) {
            savingIsEnabled = true
        } else {
            savingIsEnabled = false
        }
    }
    
    func save() {
        if mode == .create {
            do {
                blocklist.name = name
                blocklist.hostCount = hostCount
                blocklist.userDistractions.append(objectsIn: selectedUserDistractions)
                blocklist.distractionGroups.append(objectsIn: selectedDistractionGroups)
                blocklist.distractionSourceIds.append(objectsIn: selectedDistractionSourceIds)
                blocklist.totalBlockEnabled = totalBlockEnabled
                try blocklistRepository.create(blocklist: blocklist)
            } catch {
                print("Failed to create blocklist: \(error)")
            }
        } else {
            do {
                try blocklistRepository.update(blocklist: blocklist, name: name, hostCount: hostCount, distractionGroups: Array(selectedDistractionGroups), distractionSourceIds: Array(selectedDistractionSourceIds), userDistractions: Array(selectedUserDistractions), totalBlockEnabled: totalBlockEnabled)
            } catch {
                print("Failed to update blocklist: \(error)")
            }
        }
    }
    
    func refresh() {
        resolveSavingIsEnabled()
        refreshTableViewPublisher.send()
    }
    
    func presentWebsiteSelection() {
        presentWebsiteSelectionPublisher.send()
    }
    
    func dismiss() {
        dismissBlocklistEditorPublisher.send()
    }
}

extension BlocklistEditorViewModel: DistractionSelectionResponder {
    func didSelectDistractions(selectedUserDistractions: Set<String>, selectedDistractionGroups: Set<DistractionGroup>, selectedDistractionSourceIds: Set<String>) {
        self.selectedUserDistractions = selectedUserDistractions
        self.selectedDistractionGroups = selectedDistractionGroups
        self.selectedDistractionSourceIds = selectedDistractionSourceIds
        self.refresh()
    }
    
    func didUpdateUserDistraction(oldWebsite: String, newWebsite: String) {
        do {
            let filteredBlocklists = try blocklistRepository.readAll().filter { $0.userDistractions.contains(oldWebsite) }
            for blocklist in filteredBlocklists {
                guard let userDistractionsIndex = blocklist.userDistractions.firstIndex(of: oldWebsite) else { continue }
                var newUserDistractions = Array(blocklist.userDistractions)
                newUserDistractions[userDistractionsIndex] = newWebsite
                try blocklistRepository.update(blocklist: blocklist, userDistractions: newUserDistractions)
            }
        } catch {
            print("Error updating blocklists for updated website: \(error)")
        }
    }
    
    func didDeleteUserDistraction(website: String) {
        do {
            let filteredBlocklists = try blocklistRepository.readAll().filter { $0.userDistractions.contains(website) }
            for blocklist in filteredBlocklists {
                guard let userDistractionsIndex = blocklist.userDistractions.firstIndex(of: website) else { continue }
                var newUserDistractions = Array(blocklist.userDistractions)
                newUserDistractions.remove(at: userDistractionsIndex)
                try blocklistRepository.update(blocklist: blocklist, userDistractions: newUserDistractions)
            }
        } catch {
            print("Error updating blocklists for deleted website: \(error)")
        }
    }
}
