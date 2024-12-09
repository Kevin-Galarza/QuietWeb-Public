//
//  Blocklist.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/4/24.
//

import Foundation
import RealmSwift

class Blocklist: Object {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted(indexed: true) var name: String = ""
    @Persisted var hostCount: Int = 0
    @Persisted var userDistractions: List<String> = List<String>()
    @Persisted var distractionGroups: List<DistractionGroup> = List<DistractionGroup>()
    @Persisted var distractionSourceIds: List<String> = List<String>()
    @Persisted var totalBlockEnabled: Bool = false
    @Persisted var dateCreated: Date = Date()
    @Persisted var dateModified: Date = Date()

    override class func indexedProperties() -> [String] {
        return ["name"]
    }
    
    override class func primaryKey() -> String? {
        return "_id"
    }
}
