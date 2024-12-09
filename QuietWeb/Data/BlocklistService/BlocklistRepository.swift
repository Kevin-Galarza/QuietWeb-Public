//
//  BlocklistRepository.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import RealmSwift

class BlocklistRepository {
    private let dataStore: BlocklistDataStore
    
    init(dataStore: BlocklistDataStore) {
        self.dataStore = dataStore
    }
    
    func create(blocklist: Blocklist) throws {
        try dataStore.create(blocklist: blocklist)
    }
    
    func readAll() throws -> [Blocklist] {
        return try dataStore.readAll()
    }
    
    func read(id: ObjectId) throws -> Blocklist? {
        return try dataStore.read(id: id)
    }
    
    func update(blocklist: Blocklist, name: String? = nil, hostCount: Int? = nil, distractionGroups: [DistractionGroup]? = nil, distractionSourceIds: [String]? = nil, userDistractions: [String]? = nil, totalBlockEnabled: Bool? = nil) throws {
        try dataStore.update(blocklist: blocklist, name: name, hostCount: hostCount, distractionGroups: distractionGroups, distractionSourceIds: distractionSourceIds, userDistractions: userDistractions, totalBlockEnabled: totalBlockEnabled)
    }
    
    func delete(id: ObjectId) throws {
        try dataStore.delete(id: id)
    }
}

//class BlocklistRepository {
//    private let dataStore: BlocklistDataStore
//    
//    init(dataStore: BlocklistDataStore) {
//        self.dataStore = dataStore
//    }
//    
//    func create(blocklist: Blocklist) async throws {
//        try await dataStore.create(blocklist: blocklist)
//    }
//    
//    func readAll() async throws -> [Blocklist] {
//        return try await dataStore.readAll()
//    }
//    
//    func read(id: ObjectId) async throws -> Blocklist? {
//        return try await dataStore.read(id: id)
//    }
//    
//    func update(blocklist: Blocklist) async throws {
//        blocklist.dateModified = Date()
//        try await dataStore.update(blocklist: blocklist)
//    }
//    
//    func delete(id: ObjectId) async throws {
//        try await dataStore.delete(id: id)
//    }
//}
