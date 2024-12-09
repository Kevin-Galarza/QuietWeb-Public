//
//  BlocklistsViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import Foundation
import Combine
import RealmSwift

class BlocklistsViewModel {
    
    let blocklistRepository: BlocklistRepository
    let sessionRepository: SessionRepository
    let distractionGroupRepository: DistractionGroupRepository
    let mode: BlocklistsPresentationMode
    
    var responder: BlocklistSelectionResponder?
    
    var selectedBlocklists: [ObjectId] = [] {
        willSet {
            if newValue.isEmpty {
                savingIsEnabled = false
            } else {
                savingIsEnabled = true
            }
        }
    }
    
    var savingIsEnabled = false {
        willSet {
            savingIsEnabledPublisher.send(newValue)
        }
    }
    
    @Published var blocklists: [Blocklist] = []
    
    let savingIsEnabledPublisher = PassthroughSubject<Bool, Never>()
    let presentBlocklistEditorPublisher = PassthroughSubject<BlocklistEditorPresentationMode, Never>()
    let dismissPublisher = PassthroughSubject<Void, Never>()
    let confirmDeleteBlocklistPublisher = PassthroughSubject<Blocklist, Never>()
    
    init(blocklistRepository: BlocklistRepository, sessionRepository: SessionRepository, distractionGroupRepository: DistractionGroupRepository, mode: BlocklistsPresentationMode, responder: BlocklistSelectionResponder?) {
        self.blocklistRepository = blocklistRepository
        self.sessionRepository = sessionRepository
        self.distractionGroupRepository = distractionGroupRepository
        self.mode = mode
        self.responder = responder
        
        addDefaultBlocklistsIfNeeded()
        
        switch mode {
        case .view:
            loadBlocklists()
        case .select(let selectedBlocklists):
            self.selectedBlocklists = selectedBlocklists ?? []
            loadBlocklists()
        }
    }
    
    func refresh() {
        savingIsEnabled = !selectedBlocklists.isEmpty
        loadBlocklists()
    }
    
    // MARK: DEFAULT BLOCKLISTS
    
    private func createDefaultBlocklists() {
        let socialMediaSourceIds = distractionGroupRepository.distractionData[.socialMedia]?.map { $0.id }
        let socialMediaHostCount = distractionGroupRepository.distractionData[.socialMedia]?.flatMap { $0.hosts }.count ?? 0

        let socialMediaBlocklist = Blocklist()
        let allWebsitesBlocklist = Blocklist()
        
        socialMediaBlocklist.name = "Social Media Blocklist"
        socialMediaBlocklist.hostCount = socialMediaHostCount
        socialMediaBlocklist.distractionGroups.append(.socialMedia)
        socialMediaBlocklist.distractionSourceIds.append(objectsIn: socialMediaSourceIds ?? [])
        
        allWebsitesBlocklist.name = "All Websites Blocklist"
        allWebsitesBlocklist.totalBlockEnabled = true
        
        do {
            try blocklistRepository.create(blocklist: socialMediaBlocklist)
            try blocklistRepository.create(blocklist: allWebsitesBlocklist)
        } catch {
            print("Error creating default blocklists: \(error)")
        }
    }
    
    private func addDefaultBlocklistsIfNeeded() {
        let key = "shouldCreateDefaultBlocklists"
        if UserDefaults.standard.object(forKey: key) == nil {
            // Flag does not exist, create default blocklists
            createDefaultBlocklists()
            UserDefaults.standard.set(false, forKey: key)
        }
    }
    
    // MARK: CRUD
    
    private func loadBlocklists() {
        do {
            let blocklists = try blocklistRepository.readAll()
            self.blocklists = blocklists
        } catch {
            print("Failed to load blocklists: \(error)")
        }
    }
    
    func addBlocklist() {
        presentBlocklistEditorPublisher.send(.create)
    }
    
    func editBlocklist(_ blocklist: Blocklist) {
        presentBlocklistEditorPublisher.send(.edit(blocklist: blocklist))
    }
    
    func confirmDeleteBlocklist(blocklist: Blocklist) {
        confirmDeleteBlocklistPublisher.send(blocklist)
    }
    
    func deleteBlocklist(id: ObjectId) {
        do {
            try blocklistRepository.delete(id: id)
            let sessions = try sessionRepository.readAll()
            let filteredSessions = sessions.filter { $0.blocklists.contains(id) }
            for session in filteredSessions {
                guard let index = session.blocklists.firstIndex(of: id) else { continue }
                var newBlocklists = Array(session.blocklists)
                newBlocklists.remove(at: index)
                try sessionRepository.update(session: session, blocklists: newBlocklists)
            }
            refresh()
        } catch {
            print("Failed to delete blocklist: \(error)")
        }
    }
    
    func save() {
        responder?.didSelectBlocklists(selectedBlocklists: selectedBlocklists)
        dismiss()
    }
    
    func dismiss() {
        dismissPublisher.send()
    }
    
    // MARK: HELPERS
    
    func toggleSelection(for blocklist: Blocklist) {
        if let index = selectedBlocklists.firstIndex(of: blocklist._id) {
            selectedBlocklists.remove(at: index)
        } else {
            selectedBlocklists.append(blocklist._id)
        }
        
    }
    
    func isSelected(blocklist: Blocklist) -> Bool {
        return selectedBlocklists.contains(blocklist._id)
    }
    
    func blocklistDescription(blocklist: Blocklist) -> String {
        return blocklist.totalBlockEnabled ? "Blocks all Safari web browsing" : "Blocks \(blocklist.distractionSourceIds.count) distraction sources"
    }
}
