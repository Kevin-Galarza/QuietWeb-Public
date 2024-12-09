//
//  JsonWebsiteGroupDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/5/24.
//

import Foundation

class JsonDistractionGroupDataStore: DistractionGroupDataStore {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    private func bundleFilePath(for group: DistractionGroup) -> URL? {
        return bundle.url(forResource: group.fileName, withExtension: "json")
    }
    
    private func readFile(for group: DistractionGroup) throws -> [DistractionSource] {
        guard let bundlePath = bundleFilePath(for: group) else {
            throw NSError(domain: "JsonWebsiteGroupDataStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(group.fileName).json not found in bundle."])
        }
        let path = bundlePath
        
        let data = try Data(contentsOf: path)
        let websites = try JSONDecoder().decode([DistractionSource].self, from: data)
        return websites
    }
    
    func read(group: DistractionGroup) throws -> [DistractionSource] {
        return try readFile(for: group)
    }
}
