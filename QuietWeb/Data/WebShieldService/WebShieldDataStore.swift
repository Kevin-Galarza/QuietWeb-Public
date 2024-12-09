//
//  WebShieldDataStore.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/9/24.
//

import Foundation
import RealmSwift

protocol WebShieldDataStore {
    func create(webShield: WebShield) throws
    func read() throws -> [WebShield]
    func update(webShield: WebShield, enabledWebShieldGroups: [WebShieldGroup]?, enabledWebShieldBlocklists: [WebShieldBlocklist]?) throws
    func delete(id: ObjectId) throws
}
