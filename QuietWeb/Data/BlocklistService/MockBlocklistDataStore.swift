//
//  MockBlocklistDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/11/24.
//

import Foundation
import RealmSwift

//class MockBlocklistDataStore: BlocklistDataStore {
//    private var blocklists: [Blocklist] = []
//    
//    init() {
//        // dummy data
//        let blocklist1 = Blocklist()
//        blocklist1.name = "Social Media"
//        blocklist1.websites.append(objectsIn: ["facebook.com", "twitter.com", "instagram.com"])
//        
//        let blocklist2 = Blocklist()
//        blocklist2.name = "News"
//        blocklist2.websites.append(objectsIn: ["cnn.com", "bbc.com", "nytimes.com"])
//        
//        let blocklist3 = Blocklist()
//        blocklist3.name = "Block Everything"
//        blocklist3.totalBlockEnabled = true
//        
////        blocklists = [blocklist1, blocklist2, blocklist3]
//    }
//    
//    func create(blocklist: Blocklist) async throws {
//        blocklists.append(blocklist)
//    }
//    
//    func readAll() async throws -> [Blocklist] {
//        return blocklists
//    }
//    
//    func read(id: ObjectId) async throws -> Blocklist? {
//        return blocklists.first { $0._id == id }
//    }
//    
//    func update(blocklist: Blocklist) async throws {
//        if let index = blocklists.firstIndex(where: { $0._id == blocklist._id }) {
//            blocklists[index] = blocklist
//        }
//    }
//    
//    func delete(id: ObjectId) async throws {
//        if let index = blocklists.firstIndex(where: { $0._id == id }) {
//            blocklists.remove(at: index)
//        }
//    }
//}
