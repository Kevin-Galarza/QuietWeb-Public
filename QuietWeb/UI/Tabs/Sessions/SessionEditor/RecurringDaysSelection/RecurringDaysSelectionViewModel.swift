//
//  RecurringDaysSelectionViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/19/24.
//

import Foundation
import Combine

enum WeekdaySelectionPreset: String, CaseIterable {
    case everyday = "Every Day"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
}

class RecurringDaysSelectionViewModel {
    
    let responder: RecurringDaysSelectionResponder
    let provider: RecurringDaysSelectionProvider
    
    var selectedPreset: WeekdaySelectionPreset?
    var selectedWeekdays: Set<Weekday> = []
    
    let refreshTableViewPublisher = PassthroughSubject<Void, Never>()
    let dismissPublisher = PassthroughSubject<Void, Never>()
    
    init(responder: RecurringDaysSelectionResponder, provider: RecurringDaysSelectionProvider) {
        self.responder = responder
        self.provider = provider
        
        self.selectedWeekdays = provider.recurringDays
        // TODO: need to update selected preset here for provided days, if needed.
    }
    
    func handlePresetSelection(_ preset: WeekdaySelectionPreset) {
        selectedPreset = preset
        selectedWeekdays = []
        switch preset {
        case .everyday: 
            Weekday.allCases.forEach { selectedWeekdays.insert($0) }
        case .weekdays:
            selectedWeekdays = selectedWeekdays.union([.monday, .tuesday, .wednesday, .thursday, .friday])
        case .weekends:
            selectedWeekdays = selectedWeekdays.union([.saturday, .sunday])
        }
        refresh()
    }
    
    func handleWeekdaySelection(_ weekday: Weekday) {
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }

        // Update the preset based on the selected days
        if selectedWeekdays == Set(Weekday.allCases) {
            selectedPreset = .everyday
        } else if selectedWeekdays == Set([.monday, .tuesday, .wednesday, .thursday, .friday]) {
            selectedPreset = .weekdays
        } else if selectedWeekdays == Set([.saturday, .sunday]) {
            selectedPreset = .weekends
        } else {
            selectedPreset = nil
        }

        refresh()
    }
    
    func refresh() {
        refreshTableViewPublisher.send()
    }
    
    func save() {
        responder.didUpdateSelectedDays(selectedDays: selectedWeekdays)
        dismiss()
    }
    
    func dismiss() {
        dismissPublisher.send()
    }
}
