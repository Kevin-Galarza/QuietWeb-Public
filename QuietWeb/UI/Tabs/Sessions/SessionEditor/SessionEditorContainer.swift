//
//  SessionEditorContainer.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import Foundation

class SessionEditorContainer {
    
    let sessionRepository: SessionRepository
    let blocklistRepository: BlocklistRepository
    let mode: SessionEditorPresentationMode
    
    let blocklistsViewControllerFactory: (BlocklistsPresentationMode, BlocklistSelectionResponder) -> BlocklistsViewController
    
    init(sessionRepository: SessionRepository, blocklistRepository: BlocklistRepository, mode: SessionEditorPresentationMode, blocklistsViewControllerFactory: @escaping (BlocklistsPresentationMode, BlocklistSelectionResponder) -> BlocklistsViewController) {
        self.sessionRepository = sessionRepository
        self.blocklistRepository = blocklistRepository
        self.blocklistsViewControllerFactory = blocklistsViewControllerFactory
        self.mode = mode
    }
    
    // Session Editor
    
    func makeSessionEditorViewModel(responder: SessionEditorResponder) -> SessionEditorViewModel {
        return SessionEditorViewModel(sessionRepository: sessionRepository, blocklistRepository: blocklistRepository, mode: mode, responder: responder)
    }
    
    func makeSessionEditorViewController(responder: SessionEditorResponder) -> SessionEditorViewController {
        let viewModel = makeSessionEditorViewModel(responder: responder)
        
        let recurringDaysSelectionFactory = { (responder: RecurringDaysSelectionResponder, provider: RecurringDaysSelectionProvider) in
            return self.makeRecurringDaysSelectionViewController(responder: responder, provider: provider)
        }
        
        return SessionEditorViewController(viewModel: viewModel, blocklistsViewControllerFactory: blocklistsViewControllerFactory, recurringDaysSelectionViewControllerFactory: recurringDaysSelectionFactory)
    }
    
    // Recurring Days Selection
    
    func makeRecurringDaysSelectionViewModel(responder: RecurringDaysSelectionResponder, provider: RecurringDaysSelectionProvider) -> RecurringDaysSelectionViewModel {
        return RecurringDaysSelectionViewModel(responder: responder, provider: provider)
    }
    
    func makeRecurringDaysSelectionViewController(responder: RecurringDaysSelectionResponder, provider: RecurringDaysSelectionProvider) -> RecurringDaysSelectionViewController {
        let viewModel = makeRecurringDaysSelectionViewModel(responder: responder, provider: provider)
        return RecurringDaysSelectionViewController(viewModel: viewModel)
    }
}
