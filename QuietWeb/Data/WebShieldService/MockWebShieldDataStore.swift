//
//  MockWebShieldDataStore.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/10/24.
//

import Foundation
import RealmSwift

class MockWebShieldDataStore: WebShieldDataStore {
    var webShields: [WebShield] = []
    
    func create(webShield: WebShield) throws {
        webShields.append(webShield)
    }

    func read() throws -> [WebShield] {
        return webShields
    }

    func update(webShield: WebShield, enabledWebShieldGroups: [WebShieldGroup]?, enabledWebShieldBlocklists: [WebShieldBlocklist]?) throws {
        if let enabledWebShieldGroups = enabledWebShieldGroups {
            webShield.enabledWebShieldGroups.removeAll()
            webShield.enabledWebShieldGroups.append(objectsIn: enabledWebShieldGroups)
        }
        if let enabledWebShieldBlocklists = enabledWebShieldBlocklists {
            webShield.enabledWebShieldBlocklists.removeAll()
            webShield.enabledWebShieldBlocklists.append(objectsIn: enabledWebShieldBlocklists)
        }
        if let index = webShields.firstIndex(where: { $0._id == webShield._id }) {
            webShields[index] = webShield
        }
    }

    func delete(id: ObjectId) throws {
        if let index = webShields.firstIndex(where: { $0._id == id }) {
            webShields.remove(at: index)
        }
    }
}
