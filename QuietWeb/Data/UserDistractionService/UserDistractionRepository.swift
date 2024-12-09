//
//  UserDistractionRepository.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/26/24.
//

import Foundation

class UserDistractionRepository {
    private let dataStore: UserDistractionDataStore
    
    init(dataStore: UserDistractionDataStore) {
        self.dataStore = dataStore
    }
    
    func read() throws -> [String] {
        return try dataStore.read()
    }
    
    func add(website: String) throws {
        try dataStore.add(website: website)
    }
    
    func update(from oldWebsite: String, to newWebsite: String) throws {
        try dataStore.update(from: oldWebsite, to: newWebsite)
    }
    
    func delete(website: String) throws {
        try dataStore.delete(website: website)
    }
}
