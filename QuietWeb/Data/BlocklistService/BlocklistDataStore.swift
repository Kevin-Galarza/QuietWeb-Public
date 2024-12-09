//
//  BlocklistDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import RealmSwift

protocol BlocklistDataStore {
    func create(blocklist: Blocklist) throws
    func readAll() throws -> [Blocklist]
    func read(id: ObjectId) throws -> Blocklist?
    func update(blocklist: Blocklist, name: String?, hostCount: Int?, distractionGroups: [DistractionGroup]?, distractionSourceIds: [String]?, userDistractions: [String]?, totalBlockEnabled: Bool?) throws
    func delete(id: ObjectId) throws
}
