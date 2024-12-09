//
//  RealmWebShieldDataStore.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import Foundation
import RealmSwift

class RealmWebShieldDataStore: WebShieldDataStore {

    func create(webShield: WebShield) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(webShield)
        }
    }

    func read() throws -> [WebShield] {
        let realm = try Realm()
        return Array(realm.objects(WebShield.self))
    }

    func update(webShield: WebShield, enabledWebShieldGroups: [WebShieldGroup]?, enabledWebShieldBlocklists: [WebShieldBlocklist]?) throws {
        let realm = try Realm()
        try realm.write {
            if let enabledWebShieldGroups = enabledWebShieldGroups {
                webShield.enabledWebShieldGroups.removeAll()
                webShield.enabledWebShieldGroups.append(objectsIn: enabledWebShieldGroups)
            }
            if let enabledWebShieldBlocklists = enabledWebShieldBlocklists {
                webShield.enabledWebShieldBlocklists.removeAll()
                webShield.enabledWebShieldBlocklists.append(objectsIn: enabledWebShieldBlocklists)
            }
            webShield.dateModified = Date()
        }
    }

    func delete(id: ObjectId) throws {
        let realm = try Realm()
        if let session = realm.object(ofType: WebShield.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(session)
            }
        }
    }
}
