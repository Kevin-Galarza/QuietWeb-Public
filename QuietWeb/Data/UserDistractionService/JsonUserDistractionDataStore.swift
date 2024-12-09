//
//  JsonUserDistractionDataStore.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/26/24.
//

import Foundation

class JsonUserDistractionDataStore: UserDistractionDataStore {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func documentsFilePath() -> URL {
        return documentsDirectory.appendingPathComponent("user").appendingPathExtension("json")
    }
    
    private func readFile() throws -> [String] {
        let path = documentsFilePath()
        if !fileManager.fileExists(atPath: path.path) {
            return []
        }
        
        let data = try Data(contentsOf: path)
        let websites = try JSONDecoder().decode([String].self, from: data)
        return websites
    }
    
    private func writeFile(_ websites: [String]) throws {
        let path = documentsFilePath()
        let data = try JSONEncoder().encode(websites)
        try data.write(to: path, options: .atomic)
    }
    
    func read() throws -> [String] {
        return try readFile()
    }
    
    func add(website: String) throws {
        var websites = try readFile()
        guard !websites.contains(website) else { return }
        websites.append(website)
        try writeFile(websites)
    }
    
    func update(from oldWebsite: String, to newWebsite: String) throws {
        var websites = try readFile()
        guard let index = websites.firstIndex(of: oldWebsite) else { return }
        websites[index] = newWebsite
        try writeFile(websites)
    }
    
    func delete(website: String) throws {
        var websites = try readFile()
        guard let index = websites.firstIndex(of: website) else { return }
        websites.remove(at: index)
        try writeFile(websites)
    }
}
