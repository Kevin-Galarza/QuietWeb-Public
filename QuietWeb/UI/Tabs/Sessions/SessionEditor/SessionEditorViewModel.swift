//
//  SessionEditorViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import Foundation
import Combine
import RealmSwift

class SessionEditorViewModel: RecurringDaysSelectionProvider {
    
    let sessionRepository: SessionRepository
    let blocklistRepository: BlocklistRepository
    let session: Session
    let mode: SessionEditorPresentationMode
    let responder: SessionEditorResponder
    
    var blocklistNames: [String] = []
    var selectedBlocklists: [ObjectId] = []
    var name = "" {
        didSet {
            resolveSaveIsEnabled()
        }
    }
    var type: SessionType = .now {
        didSet {
            refresh()
        }
    }
    var startTime = Date()
    var endTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    var recurringDays: Set<Weekday> = []
    var savingIsEnabled = false {
        willSet {
            savingIsEnabledPublisher.send(newValue)
        }
    }
    
    let invalidTimePublisher = PassthroughSubject<Void, Never>()
    let savingIsEnabledPublisher = PassthroughSubject<Bool, Never>()
    let presentBlocklistsViewControllerPublisher = PassthroughSubject<BlocklistsPresentationMode, Never>()
    let presentRecurringDaysSelectionViewControllerPublisher = PassthroughSubject<Void, Never>()
    let refreshTableViewPublisher = PassthroughSubject<Void, Never>()
    let dismissPublisher = PassthroughSubject<Void, Never>()
    let verifySavePublisher = PassthroughSubject<(Date, SessionType), Never>()
    
    init(sessionRepository: SessionRepository, blocklistRepository: BlocklistRepository, mode: SessionEditorPresentationMode, responder: SessionEditorResponder) {
        self.sessionRepository = sessionRepository
        self.blocklistRepository = blocklistRepository
        self.mode = mode
        self.responder = responder
        
        switch mode {
        case .create:
            self.session = Session()
        case .edit(let session), .view(session: let session):
            self.session = session
            self.name = session.name
            self.type = session.type
            self.startTime = session.startTime
            self.endTime = session.endTime
            self.recurringDays = Set(session.recurringDays)
            self.selectedBlocklists = session.blocklists.map { $0 }
        }
    }
    
    func presentBlocklistSelection() {
        presentBlocklistsViewControllerPublisher.send(.select(selectedBlocklists: selectedBlocklists))
    }
    
    func presentRecurringDaysSelection() {
        presentRecurringDaysSelectionViewControllerPublisher.send()
    }
    
    private func loadBlocklistData() throws {
        let blocklists = try blocklistRepository.readAll()
        let blocklistIds = blocklists.map { $0._id }
        let updatedSelectedBlocklists = selectedBlocklists.filter { blocklistIds.contains($0) }
        self.selectedBlocklists = updatedSelectedBlocklists
        let filteredBlocklists = blocklists.filter { blocklist in
            self.selectedBlocklists.contains { $0 == blocklist._id }
        }
        blocklistNames = filteredBlocklists.map { $0.name }
    }
    
    func refresh() {
        do {
            try loadBlocklistData()
            resolveSaveIsEnabled()
            refreshTableViewPublisher.send()
        } catch {
            print("Error refreshing session editor: \(error)")
        }
    }
    
    func verifySave() {
        // check if the session became active via notification action while in the session editor
        if mode != .create {
            do {
                guard try sessionRepository.read(id: session._id)?.isActive == false else {
                    dismiss()
                    return
                }
            } catch {
                print(error)
            }
        }
        guard timeIsValid() else {
            invalidTimePublisher.send()
            return
        }
        verifySavePublisher.send((endTime, type))
    }
    
    func save() {
        guard timeIsValid() else {
            invalidTimePublisher.send()
            return
        }
        if mode == .create {
            do {
                session.name = name
                session.blocklists.append(objectsIn: selectedBlocklists)
                session.type = type
                session.recurringDays.append(objectsIn: recurringDays)
                session.startTime = startTime
                session.endTime = endTime
                session.isActive = type == .now ? true : false
                try sessionRepository.create(session: session)
                responder.didCreateSession(session)
            } catch {
                print("Failed to create session: \(error)")
            }
        } else {
            do {
                try sessionRepository.update(session: session, name: name, blocklists: selectedBlocklists, type: type, recurringDays: Array(recurringDays), startTime: startTime, endTime: endTime, isActive: (type == .now ? true : false))
                responder.didModifySession(session)
            } catch {
                print("Failed to update session: \(error)")
            }
        }

        dismiss()
    }
    
    func dismiss() {
        dismissPublisher.send()
    }
    
    // Helper Methods
    
    func timeIsValid() -> Bool {
        if type == .now {
            return endTime > Date()
        }
        if type == .later {
            return startTime > Date() && endTime > startTime
        }
        if type == .recurring {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
            
            // Calculate the total duration in minutes
            let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
            let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)
            
            // Calculate the duration
            let durationMinutes: Int
            if endMinutes >= startMinutes {
                durationMinutes = endMinutes - startMinutes
            } else {
                durationMinutes = (24 * 60) - startMinutes + endMinutes
            }
            
            return startTime < endTime && durationMinutes > 0
        }
        return true
    }
    
    func resolveSaveIsEnabled() {
        guard !name.isEmpty && !selectedBlocklists.isEmpty else {
            savingIsEnabled = false
            return
        }
        
        if type == .recurring {
            guard !recurringDays.isEmpty else {
                savingIsEnabled = false
                return
            }
        }
        
        savingIsEnabled = true
    }
    
    func timePickerChanged(date: Date, tag: Int) {
        if tag == 0 {
            if type == .now {
                self.endTime = date
            } else {
                self.startTime = date
            }
        }
        
        if tag == 1 {
            self.endTime = date
        }
    }
    
    func descriptionForRecurringDays() -> String {
        guard !recurringDays.isEmpty else { return "None" }
        guard recurringDays.count > 1 else { return recurringDays.first?.description ?? "None" }

        let weekdaysSet: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekendSet: Set<Weekday> = [.saturday, .sunday]
        let allDaysSet: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]

        let sortedDays = recurringDays.sorted(by: { $0.rawValue < $1.rawValue })

        let daysString: String
        if recurringDays == allDaysSet {
            daysString = "Everyday"
        } else if recurringDays == weekdaysSet {
            daysString = "Weekdays"
        } else if recurringDays == weekendSet {
            daysString = "Weekends"
        } else {
            daysString = sortedDays.map { $0.shortName }.joined(separator: "-")
        }
        return daysString
    }
    
    func formattedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    func formattedTimeString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
}

extension SessionEditorViewModel: BlocklistSelectionResponder {
    func didSelectBlocklists(selectedBlocklists: [ObjectId]) {
        self.selectedBlocklists = selectedBlocklists
        refresh()
    }
}

extension SessionEditorViewModel: RecurringDaysSelectionResponder {
    func didUpdateSelectedDays(selectedDays: Set<Weekday>) {
        self.recurringDays = selectedDays
        refresh()
    }
}
