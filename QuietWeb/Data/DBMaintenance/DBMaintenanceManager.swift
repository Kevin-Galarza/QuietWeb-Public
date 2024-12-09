//
//  DBMaintenanceManager.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 7/25/24.
//

import Foundation
import RealmSwift

class DBMaintenanceManager {

    private let realm = try! Realm()
    
    private func cleanUpExpiredSessions() {
        let expiredSessions = realm.objects(Session.self).filter("isActive == false AND endTime < %@ AND type != 3", Date())
        
        try! realm.write {
            realm.delete(expiredSessions)
        }
    }
    
    func performMaintenanceTasks() {
        cleanUpExpiredSessions()
    }
}
