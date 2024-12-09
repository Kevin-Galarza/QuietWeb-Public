//
//  RealmSessionDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/7/24.
//

import RealmSwift
import Foundation

class RealmSessionDataStore: SessionDataStore {

    func create(session: Session) throws {
        let realm = try Realm()
        try realm.write {
            realm.add(session)
        }
    }

    func readAll() throws -> [Session] {
        let realm = try Realm()
        return Array(realm.objects(Session.self))
    }

    func read(id: ObjectId) throws -> Session? {
        let realm = try Realm()
        return realm.object(ofType: Session.self, forPrimaryKey: id)
    }

    func update(session: Session, name: String?, blocklists: [ObjectId]?, type: SessionType?, recurringDays: [Weekday]?, startTime: Date?, endTime: Date?, isActive: Bool?, isExpired: Bool?) throws {
        let realm = try Realm()
        try realm.write {
            if let name = name {
                session.name = name
            }
            if let blocklists = blocklists {
                session.blocklists.removeAll()
                session.blocklists.append(objectsIn: blocklists)
            }
            if let type = type {
                session.type = type
            }
            if let recurringDays = recurringDays {
                session.recurringDays.removeAll()
                session.recurringDays.append(objectsIn: recurringDays)
            }
            if let startTime = startTime {
                session.startTime = startTime
            }
            if let endTime = endTime {
                session.endTime = endTime
            }
            if let isActive = isActive {
                session.isActive = isActive
            }
            if let isExpired = isExpired {
                session.isExpired = isExpired
            }
            session.dateModified = Date()
        }
    }

    func delete(id: ObjectId) throws {
        let realm = try Realm()
        if let session = realm.object(ofType: Session.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(session)
            }
        }
    }
}
