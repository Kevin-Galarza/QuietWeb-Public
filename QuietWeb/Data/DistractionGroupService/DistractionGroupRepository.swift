//
//  WebsiteGroupRepository.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/5/24.
//

import Foundation

class DistractionGroupRepository {
    private let dataStore: DistractionGroupDataStore
    
    let distractionData: [DistractionGroup: [DistractionSource]]
    
    init(dataStore: DistractionGroupDataStore) {
        
        func read(group: DistractionGroup) throws -> [DistractionSource] {
            return try dataStore.read(group: group)
        }
        
        func loadData() -> [DistractionGroup: [DistractionSource]] {
            var data: [DistractionGroup: [DistractionSource]] = [:]
            do {
                let groups = DistractionGroup.allCases
                for group in groups {
                    let sourceData = try read(group: group)
                    data[group] = sourceData
                }
            } catch {
                print("Error loading system distraction data: \(error)")
            }
            return data
        }
        
        self.dataStore = dataStore
        self.distractionData = loadData()
    }

    func calculateHostCount(for groups: Set<DistractionGroup>, and sourceIds: Set<String>) -> Int {
        var totalCount = 0
        for group in groups {
            if let groupSources = distractionData[group] {
                let matchingSources = groupSources.filter { sourceIds.contains($0.id) }
                let hostCount = matchingSources.reduce(0) { $0 + $1.hosts.count }
                totalCount += hostCount
            }
        }
        return totalCount
    }
}
