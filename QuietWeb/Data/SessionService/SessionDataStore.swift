//
//  SessionDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/7/24.
//

import Foundation
import RealmSwift

protocol SessionDataStore {
    func create(session: Session) throws
    func readAll() throws -> [Session]
    func read(id: ObjectId) throws -> Session?
    func update(session: Session, name: String?, blocklists: [ObjectId]?, type: SessionType?, recurringDays: [Weekday]?, startTime: Date?, endTime: Date?, isActive: Bool?, isExpired: Bool?) throws
    func delete(id: ObjectId) throws
}
