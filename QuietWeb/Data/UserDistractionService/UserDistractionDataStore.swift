//
//  UserDistractionDataStore.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/26/24.
//

import Foundation

protocol UserDistractionDataStore {
    func read() throws -> [String]
    func add(website: String) throws
    func update(from oldWebsite: String, to newWebsite: String) throws
    func delete(website: String) throws
}
