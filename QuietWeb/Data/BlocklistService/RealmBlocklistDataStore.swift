//
//  RealmBlocklistDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import RealmSwift

class RealmBlocklistDataStore: BlocklistDataStore {

    func create(blocklist: Blocklist) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(blocklist)
        }
    }

    func readAll() throws -> [Blocklist] {
        let realm = try Realm()
        return Array(realm.objects(Blocklist.self))
    }

    func read(id: ObjectId) throws -> Blocklist? {
        let realm = try Realm()
        return realm.object(ofType: Blocklist.self, forPrimaryKey: id)
    }

    func update(blocklist: Blocklist, name: String?, hostCount: Int?, distractionGroups: [DistractionGroup]?, distractionSourceIds: [String]?, userDistractions: [String]?, totalBlockEnabled: Bool?) throws {
        let realm = try Realm()
        try realm.write {
            if let name = name {
                blocklist.name = name
            }
            if let hostCount = hostCount {
                blocklist.hostCount = hostCount
            }
            if let distractionGroups = distractionGroups {
                blocklist.distractionGroups.removeAll()
                blocklist.distractionGroups.append(objectsIn: distractionGroups)
            }
            if let distractionSourceIds = distractionSourceIds {
                blocklist.distractionSourceIds.removeAll()
                blocklist.distractionSourceIds.append(objectsIn: distractionSourceIds)
            }
            if let userDistractions = userDistractions {
                blocklist.userDistractions.removeAll()
                blocklist.userDistractions.append(objectsIn: userDistractions)
            }
            if let totalBlockEnabled = totalBlockEnabled {
                blocklist.totalBlockEnabled = totalBlockEnabled
            }
            blocklist.dateModified = Date()
        }
    }

    func delete(id: ObjectId) throws {
        let realm = try Realm()
        if let blocklist = realm.object(ofType: Blocklist.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(blocklist)
            }
        }
    }
}

//class RealmBlocklistDataStore: BlocklistDataStore {
//    private let configuration = Realm.Configuration()
//    
//    private func performRealmOperation<T>(_ block: @escaping (Realm) throws -> T) async throws -> T {
//        return try await withCheckedThrowingContinuation { continuation in
//            DispatchQueue(label: "realmQueue").async {
//                do {
//                    let realm = try Realm(configuration: self.configuration)
//                    let result = try block(realm)
//                    continuation.resume(returning: result)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func create(blocklist: Blocklist) async throws {
//        try await performRealmOperation { realm in
//            try realm.write {
//                realm.add(blocklist)
//            }
//        }
//    }
//    
//    func readAll() async throws -> [Blocklist] {
//        return try await performRealmOperation { realm in
//            return Array(realm.objects(Blocklist.self))
//        }
//    }
//    
//    func read(id: ObjectId) async throws -> Blocklist? {
//        return try await performRealmOperation { realm in
//            return realm.object(ofType: Blocklist.self, forPrimaryKey: id)
//        }
//    }
//    
//    func update(blocklist: Blocklist) async throws {
//        try await performRealmOperation { realm in
//            try realm.write {
//                realm.add(blocklist, update: .modified)
//            }
//        }
//    }
//    
//    func delete(id: ObjectId) async throws {
//        try await performRealmOperation { realm in
//            if let blocklist = realm.object(ofType: Blocklist.self, forPrimaryKey: id) {
//                try realm.write {
//                    realm.delete(blocklist)
//                }
//            }
//        }
//    }
//}
