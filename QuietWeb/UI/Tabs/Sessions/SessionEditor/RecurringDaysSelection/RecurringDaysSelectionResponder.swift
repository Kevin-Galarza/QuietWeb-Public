//
//  RecurringDaysSelectionResponder.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/19/24.
//

import Foundation

protocol RecurringDaysSelectionResponder: AnyObject {
    func didUpdateSelectedDays(selectedDays: Set<Weekday>)
}
