//
//  BlocklistEditorContainer.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/12/24.
//

import Foundation

class BlocklistEditorContainer {
    
    let distractionGroupRepository: DistractionGroupRepository
    let blocklistRepository: BlocklistRepository
    
    let mode: BlocklistEditorPresentationMode
    
    init(distractionGroupRepository: DistractionGroupRepository, blocklistRepository: BlocklistRepository, mode: BlocklistEditorPresentationMode) {
        self.distractionGroupRepository = distractionGroupRepository
        self.blocklistRepository = blocklistRepository
        self.mode = mode
    }
    
    // User Distraction Repository
    
    func makeUserDistractionDataStore() -> UserDistractionDataStore {
        return JsonUserDistractionDataStore()
    }
    
    func makeUserDistractionRepository() -> UserDistractionRepository {
        let dataStore = makeUserDistractionDataStore()
        return UserDistractionRepository(dataStore: dataStore)
    }
    
    // Blocklist Editor
    
    func makeBlocklistEditorViewModel() -> BlocklistEditorViewModel {
        return BlocklistEditorViewModel(blocklistRepository: blocklistRepository, distractionGroupRepository: distractionGroupRepository, mode: mode)
    }
    
    func makeBlocklistEditorViewController() -> BlocklistEditorViewController {
        let viewModel = makeBlocklistEditorViewModel()
        
        let websiteSelectionFactory = { (responder: DistractionSelectionResponder, provider: DistractionSelectionDataProvider) in
            return self.makeWebsiteSelectionViewController(responder: responder, provider: provider)
        }
        
        return BlocklistEditorViewController(viewModel: viewModel, websiteSelectionViewControllerFactory: websiteSelectionFactory)
    }
    
    // Website Selection
    
    func makeWebsiteSelectionViewModel(responder: DistractionSelectionResponder, provider: DistractionSelectionDataProvider) -> DistractionSelectionViewModel {
        let userDistractionRepository = makeUserDistractionRepository()
        return DistractionSelectionViewModel(responder: responder, provider: provider, distractionGroupRepository: distractionGroupRepository, userDistractionRepository: userDistractionRepository)
    }
    
    func makeWebsiteSelectionViewController(responder: DistractionSelectionResponder, provider: DistractionSelectionDataProvider) -> DistractionSelectionViewController {
        let viewModel = makeWebsiteSelectionViewModel(responder: responder, provider: provider)
        
        let systemWebsiteInfoFactory = { (responder: DistractionSourceSelectionResponder, provider: DistractionSourceSelectionDataProvider, distractionGroup: DistractionGroup) in
            return self.makeSystemWebsiteInfoViewController(responder: responder, provider: provider, distractionGroup: distractionGroup)
        }
        
        return DistractionSelectionViewController(viewModel: viewModel, systemWebsiteInfoViewControllerFactory: systemWebsiteInfoFactory)
    }
    
    // System Website Info
    
    func makeSystemWebsiteInfoViewModel(responder: DistractionSourceSelectionResponder, provider: DistractionSourceSelectionDataProvider, distractionGroup: DistractionGroup) -> DistractionSourceSelectionViewModel {
        return DistractionSourceSelectionViewModel(responder: responder, provider: provider, distractionGroupRepository: distractionGroupRepository, distractionGroup: distractionGroup )
    }
    
    func makeSystemWebsiteInfoViewController(responder: DistractionSourceSelectionResponder, provider: DistractionSourceSelectionDataProvider, distractionGroup: DistractionGroup) -> DistractionSourceSelectionViewController {
        let viewModel = makeSystemWebsiteInfoViewModel(responder: responder, provider: provider, distractionGroup: distractionGroup)
        return DistractionSourceSelectionViewController(viewModel: viewModel)
    }
}
