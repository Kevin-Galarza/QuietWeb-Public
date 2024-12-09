//
//  SystemWebsiteInfoViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/15/24.
//

import Foundation
import Combine

class DistractionSourceSelectionViewModel {
    
    enum BulkToggleState: String {
        case select = "Select All"
        case deselect = "Deselect All"
    }
    
    let responder: DistractionSourceSelectionResponder
    let provider: DistractionSourceSelectionDataProvider
    let distractionGroupRepository: DistractionGroupRepository
    let distractionGroup: DistractionGroup
    
    var sources: [DistractionSource] = []
    var selectedDistractionSourceIds: Set<String>
    
    var bulkToggleState: BulkToggleState = .select
    
    let dismissPublisher = PassthroughSubject<Void, Never>()
    let refreshPublisher = PassthroughSubject<Void, Never>()
    
    init(responder: DistractionSourceSelectionResponder, provider: DistractionSourceSelectionDataProvider, distractionGroupRepository: DistractionGroupRepository, distractionGroup: DistractionGroup) {
        
        func extractGroupSourceIds(_ ids: Set<String>, group: DistractionGroup) -> Set<String> {
            let groupSourceIds = distractionGroupRepository.distractionData[group]?.map { $0.id } ?? []
            return ids.filter { groupSourceIds.contains($0) }
        }
        
        self.responder = responder
        self.provider = provider
        self.distractionGroupRepository = distractionGroupRepository
        self.distractionGroup = distractionGroup
        self.selectedDistractionSourceIds = extractGroupSourceIds(provider.selectedDistractionSourceIds, group: distractionGroup)
        loadSources(group: distractionGroup)
        resolveBulkToggleState()
        refresh()
    }
    
    private func loadSources(group: DistractionGroup) {
        sources = distractionGroupRepository.distractionData[group] ?? []
    }
    
    private func resolveBulkToggleState() {
        if selectedDistractionSourceIds.count == sources.count {
            bulkToggleState = .deselect
        } else {
            bulkToggleState = .select
        }
    }
    
    func sourceIsSelected(index: Int) -> Bool {
        let source = sources[index]
        return selectedDistractionSourceIds.contains(source.id)
    }
    
    func handleSourceToggleAll() {
        let sourceIds = sources.map { $0.id }
        if bulkToggleState == .deselect {
            selectedDistractionSourceIds.removeAll()
        } else {
            selectedDistractionSourceIds.formUnion(sourceIds)
        }
        resolveBulkToggleState()
        refresh()
    }
    
    func handleSourceToggle(index: Int) {
        let source = sources[index]
        if selectedDistractionSourceIds.contains(source.id) {
            selectedDistractionSourceIds.remove(source.id)
        } else {
            selectedDistractionSourceIds.insert(source.id)
        }
        resolveBulkToggleState()
        refresh()
    }
    
    func refresh() {
        refreshPublisher.send()
    }
    
    func dismiss() {
        dismissPublisher.send()
    }
    
    func save() {
        let unselectedSourceIds = sources
            .map { $0.id }
            .filter { !selectedDistractionSourceIds.contains($0) }
        responder.didSelectDistractionSources(group: distractionGroup, selectedDistractionSourceIds: selectedDistractionSourceIds, unselectedDistractionSourceIds: Set(unselectedSourceIds))
        dismiss()
    }
}
