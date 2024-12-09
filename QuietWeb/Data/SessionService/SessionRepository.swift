//
//  SessionRepository.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/7/24.
//

import Foundation
import RealmSwift

class SessionRepository {
    private let dataStore: SessionDataStore
    
    init(dataStore: SessionDataStore) {
        self.dataStore = dataStore
    }
    
    func create(session: Session) throws {
        try dataStore.create(session: session)
    }
    
    func readAll() throws -> [Session] {
        return try dataStore.readAll()
    }
    
    func read(id: ObjectId) throws -> Session? {
        return try dataStore.read(id: id)
    }
    
    func update(session: Session, name: String? = nil, blocklists: [ObjectId]? = nil, type: SessionType? = nil, recurringDays: [Weekday]? = nil, startTime: Date? = nil, endTime: Date? = nil, isActive: Bool? = nil, isExpired: Bool? = nil) throws {
        try dataStore.update(session: session, name: name, blocklists: blocklists, type: type, recurringDays: recurringDays, startTime: startTime, endTime: endTime, isActive: isActive, isExpired: isExpired)
    }
    
    func delete(id: ObjectId) throws {
        try dataStore.delete(id: id)
    }
}

//class SessionRepository {
//    private let dataStore: SessionDataStore
//    
//    init(dataStore: SessionDataStore) {
//        self.dataStore = dataStore
//    }
//    
//    func create(session: Session) async throws {
//        try await dataStore.create(session: session)
//    }
//    
//    func readAll() async throws -> [Session] {
//        return try await dataStore.readAll()
//    }
//    
//    func read(id: ObjectId) async throws -> Session? {
//        return try await dataStore.read(id: id)
//    }
//    
//    func update(session: Session) async throws {
//        session.dateModified = Date()
//        try await dataStore.update(session: session)
//    }
//    
//    func delete(id: ObjectId) async throws {
//        try await dataStore.delete(id: id)
//    }
//}
