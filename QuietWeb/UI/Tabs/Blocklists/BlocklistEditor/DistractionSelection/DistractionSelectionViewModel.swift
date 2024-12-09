//
//  WebsiteSelectionViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import UIKit
import Combine

class DistractionSelectionViewModel: DistractionSourceSelectionDataProvider {
    
    enum UserDistractionSelectionOperation {
        case add(website: String)
        case delete(website: String)
        case update(oldWebsite: String, newWebsite: String)
    }
    
    let responder: DistractionSelectionResponder
    let provider: DistractionSelectionDataProvider
    let distractionGroupRepository: DistractionGroupRepository
    let userDistractionRepository: UserDistractionRepository

    var selectedUserDistractions: Set<String>
    var selectedDistractionGroups: Set<DistractionGroup>
    var selectedDistractionSourceIds: Set<String>
    
    var userDistractionsBulkSelectName: String = ""
    var distractionGroupsBulkSelectName: String = ""
    
    var operationQueue: [UserDistractionSelectionOperation] = []
    
    let dismissPublisher = PassthroughSubject<Void, Never>()
    let presentSystemWebsiteInfoPublisher = PassthroughSubject<(DistractionSourceSelectionResponder, DistractionSourceSelectionDataProvider, DistractionGroup), Never>()
    let presentUserWebsiteEditorPublisher = PassthroughSubject<String?, Never>()
    let refreshPublisher = PassthroughSubject<Void, Never>()
    
    @Published var userDistractions: [String] = []
    
    init(responder: DistractionSelectionResponder, provider: DistractionSelectionDataProvider, distractionGroupRepository: DistractionGroupRepository, userDistractionRepository: UserDistractionRepository) {
        self.responder = responder
        self.provider = provider
        self.distractionGroupRepository = distractionGroupRepository
        self.userDistractionRepository = userDistractionRepository
        self.selectedUserDistractions = provider.selectedUserDistractions
        self.selectedDistractionGroups = provider.selectedDistractionGroups
        self.selectedDistractionSourceIds = provider.selectedDistractionSourceIds
        
        loadUserDistractions()
    }
    
    func refresh() {
        refreshPublisher.send()
    }
    
    func updateBulkSelectNames() {
        if userDistractions.isEmpty {
            userDistractionsBulkSelectName = "Select All"
        } else {
            userDistractionsBulkSelectName = userDistractions.allSatisfy { selectedUserDistractions.contains($0) } ? "Deselect All" : "Select All"
        }
        distractionGroupsBulkSelectName = DistractionGroup.allCases.allSatisfy { selectedDistractionGroups.contains($0) } ? "Deselect All" : "Select All"
        refresh()
    }
    
    func bulkSelectNameForSection(_ section: Int) -> String {
        switch section {
        case 0: return userDistractionsBulkSelectName
        case 1: return distractionGroupsBulkSelectName
        default: return ""
        }
    }
    
    func handleSelectAll(for section: Int) {
        switch section {
        case 0:
            toggleUserDistractionSelectionAll()
        case 1:
            toggleDistractionGroupSelectionAll()
        default:
            return
        }
        updateBulkSelectNames()
    }
    
    private func toggleUserDistractionSelectionAll() {
        if selectedUserDistractions.count == userDistractions.count {
            selectedUserDistractions.removeAll()
        } else {
            selectedUserDistractions = Set(userDistractions)
        }
    }

    private func toggleDistractionGroupSelectionAll() {
        let allItemsIncluded = DistractionGroup.allCases.count == selectedDistractionGroups.count
        if allItemsIncluded {
            selectedDistractionGroups.removeAll()
            selectedDistractionSourceIds.removeAll()
        } else {
            selectedDistractionGroups.formUnion(DistractionGroup.allCases)
            let sources = distractionGroupRepository.distractionData.values.flatMap { $0 }
            let ids = sources.map { $0.id }
            selectedDistractionSourceIds.formUnion(ids)
        }
    }
    
    // call this when user toggles distraction group from DistractionSelectionView table, should remove all source ids for group when toggled off, add all source ids for group when toggled on
    func handleDistractionGroupToggle(group: DistractionGroup) {
        guard let groupSourceIds = distractionGroupRepository.distractionData[group]?.map({ $0.id }) else { return }
        if selectedDistractionGroups.contains(group) {
            groupSourceIds.forEach { selectedDistractionSourceIds.remove($0) }
        } else {
            selectedDistractionSourceIds.formUnion(groupSourceIds)
        }
    }
    
    func loadUserDistractions() {
        do {
            userDistractions = try userDistractionRepository.read()
            updateBulkSelectNames()
        } catch {
            print("Error loading user website list, \(error).")
        }
    }
    
    func softAddUserDistraction(_ website: String) {
        guard !userDistractions.contains(website) else { return }
        userDistractions.append(website)
        selectedUserDistractions.insert(website)
        operationQueue.append(.add(website: website))
        updateBulkSelectNames()
    }
    
    func addUserDistraction(_ website: String) throws {
        try userDistractionRepository.add(website: website)
    }
    
    func softUpdateUserDistraction(oldWebsite: String, newWebsite: String) {
        guard let index = userDistractions.firstIndex(of: oldWebsite) else { return }
        userDistractions[index] = newWebsite
        selectedUserDistractions.remove(oldWebsite)
        selectedUserDistractions.insert(newWebsite)
        operationQueue.append(.update(oldWebsite: oldWebsite, newWebsite: newWebsite))
    }
    
    func updateUserDistraction(oldWebsite: String, newWebsite: String) throws {
        try userDistractionRepository.update(from: oldWebsite, to: newWebsite)
        responder.didUpdateUserDistraction(oldWebsite: oldWebsite, newWebsite: newWebsite)
    }
    
    func softDeleteUserDistraction(_ website: String) {
        guard let index = userDistractions.firstIndex(of: website) else { return }
        userDistractions.remove(at: index)
        if let index = selectedUserDistractions.firstIndex(of: website) {
            selectedUserDistractions.remove(at: index)
        }
        operationQueue.append(.delete(website: website))
        updateBulkSelectNames()
    }
    
    func deleteUserDistraction(_ website: String) throws {
        try userDistractionRepository.delete(website: website)
        responder.didDeleteUserDistraction(website: website)
    }
    
    func isValidContentBlockerURL(_ urlString: String) -> Bool {
        // Add default scheme if missing
        var processedURLString = urlString
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            processedURLString = "http://\(urlString)"
        }
        
        // Regular expression to validate URLs
        // - Starts with http or https
        // - Valid domain name with subdomains
        // - Optionally followed by a path
        let urlPattern = #"^(https?):\/\/(([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,})(\/[a-zA-Z0-9\-\._~:\/?#\[\]@!\$&'\(\)\*\+,;=]*)?$"#
        
        let regex = try? NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: processedURLString.utf16.count)
        
        if let match = regex?.firstMatch(in: processedURLString, options: [], range: range) {
            return match.range.length == processedURLString.utf16.count
        } else {
            return false
        }
    }
    
    func save() {
        Task {
            do {
                try processOperations()
                responder.didSelectDistractions(selectedUserDistractions: selectedUserDistractions, selectedDistractionGroups: selectedDistractionGroups, selectedDistractionSourceIds: selectedDistractionSourceIds)
                dismiss()
            } catch {
                print("Error saving selected websites for blocklist, \(error).")
            }
        }
    }
    
    func processOperations() throws {
        for operation in operationQueue {
            switch operation {
            case .add(let website):
                try addUserDistraction(website)
            case .update(let oldWebsite, let newWebsite) :
                try updateUserDistraction(oldWebsite: oldWebsite, newWebsite: newWebsite)
            case .delete(let website):
                try deleteUserDistraction(website)
            }
        }
    }
    
    func dismiss() {
        dismissPublisher.send()
    }
    
    // TODO: need to provide distraction group selected, and selected sources (if any)
    func presentSystemWebsiteInfo(index: Int) {
        let group = DistractionGroup.allCases[index]
        presentSystemWebsiteInfoPublisher.send((self, self, group))
    }
    
    func presentUserWebsiteEditor(mode: UserDistractionEditorPresentationMode) {
        switch mode {
        case .create:
            presentUserWebsiteEditorPublisher.send(nil)
        case .edit(let index):
            let website = userDistractions[index - 1]
            presentUserWebsiteEditorPublisher.send(website)
        }
    }
}

extension DistractionSelectionViewModel: DistractionSourceSelectionResponder {
    func didSelectDistractionSources(group: DistractionGroup, selectedDistractionSourceIds: Set<String>, unselectedDistractionSourceIds: Set<String>) {
        unselectedDistractionSourceIds.forEach { self.selectedDistractionSourceIds.remove($0)}
        self.selectedDistractionSourceIds.formUnion(selectedDistractionSourceIds)
        if selectedDistractionSourceIds.isEmpty {
            selectedDistractionGroups.remove(group)
        } else {
            selectedDistractionGroups.insert(group)
        }
        updateBulkSelectNames()
    }
}
