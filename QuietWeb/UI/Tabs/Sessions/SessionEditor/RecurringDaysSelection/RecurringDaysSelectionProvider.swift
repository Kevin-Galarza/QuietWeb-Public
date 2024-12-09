//
//  RecurringDaysSelectionProvider.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/19/24.
//

import Foundation

protocol RecurringDaysSelectionProvider: AnyObject {
    var recurringDays: Set<Weekday> { get set}
}
