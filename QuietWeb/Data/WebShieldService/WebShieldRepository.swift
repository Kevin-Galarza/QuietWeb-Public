//
//  WebShieldRepository.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import Foundation
import RealmSwift

class WebShieldRepository {
    private let dataStore: WebShieldDataStore
    
    init(dataStore: WebShieldDataStore) {
        self.dataStore = dataStore
    }
    
    func create(webShield: WebShield) throws {
        try dataStore.create(webShield: webShield)
    }
    
    func read() throws -> [WebShield] {
        return try dataStore.read()
    }
    
    func update(webShield: WebShield, enabledWebShieldGroups: [WebShieldGroup]? = nil, enabledWebShieldBlocklists: [WebShieldBlocklist]? = nil) throws {
        try dataStore.update(webShield: webShield, enabledWebShieldGroups: enabledWebShieldGroups, enabledWebShieldBlocklists: enabledWebShieldBlocklists)
    }
    
    func delete(id: ObjectId) throws {
        try dataStore.delete(id: id)
    }
}
