//
//  Session.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import RealmSwift

enum SessionType: Int, PersistableEnum {
    case none = 0
    case now = 1
    case later = 2
    case recurring = 3
    
    var name: String {
        switch self {
        case .none: return "None"
        case .now: return "Start Now"
        case .later: return "Start Later"
        case .recurring: return "Recurring"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "None"
        case .now: return "Start your session immediately"
        case .later: return "Schedule a session for a later date"
        case .recurring: return "Schedule a recurring session"
        }
    }
}

enum Weekday: Int, PersistableEnum, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortName: String {
        switch self {
        case .sunday: return "Su"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "Th"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
    
    var description: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

class Session: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted(indexed: true) var name: String = ""
    @Persisted var blocklists: List<ObjectId> = List<ObjectId>()
    @Persisted var type: SessionType = .none
    @Persisted var recurringDays: List<Weekday> = List<Weekday>()
    @Persisted var startTime: Date = Date()
    @Persisted var endTime: Date = Date()
    @Persisted var isActive: Bool = false
    @Persisted var isExpired: Bool = false
    @Persisted var dateCreated: Date = Date()
    @Persisted var dateModified: Date = Date()
    
    override class func indexedProperties() -> [String] {
        return ["name"]
    }
    
    override class func primaryKey() -> String? {
        return "_id"
    }
}
