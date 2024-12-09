//
//  MockSessionDataStore.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/16/24.
//

import Foundation
import RealmSwift

//class MockSessionDataStore: SessionDataStore {
//    private var sessions: [Session] = []
//    
//    init() {
//        func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
//            var dateComponents = DateComponents()
//            dateComponents.year = year
//            dateComponents.month = month
//            dateComponents.day = day
//            dateComponents.hour = hour
//            dateComponents.minute = minute
//            return Calendar.current.date(from: dateComponents) ?? Date()
//        }
//        
//        // dummy data
//        let session0 = Session()
//        session0.name = "Just Focus"
//        session0.type = .now
//        session0.endTime = makeDate(year: 2024, month: 7, day: 19, hour: 18, minute: 25)
//        session0.isActive = true
//        
//        let session1 = Session()
//        session1.name = "Beans Playlist 1983"
//        session1.type = .now
//        session1.endTime = makeDate(year: 2024, month: 7, day: 17, hour: 12, minute: 0)
//        session1.isActive = true
//        
//        let session2 = Session()
//        session2.name = "My Morning"
//        session2.type = .later
//        session2.startTime = makeDate(year: 2024, month: 7, day: 19, hour: 8, minute: 30)
//        session2.endTime = makeDate(year: 2024, month: 7, day: 19, hour: 18, minute: 0)
//        
//        let session3 = Session()
//        session3.name = "Poop Focus"
//        session3.type = .later
//        session3.startTime = makeDate(year: 2024, month: 7, day: 19, hour: 18, minute: 30)
//        session3.endTime = makeDate(year: 2024, month: 7, day: 19, hour: 20, minute: 0)
//        
//        let session4 = Session()
//        session4.name = "Weekday Focus"
//        session4.type = .recurring
//        session4.startTime = makeDate(year: 2024, month: 7, day: 19, hour: 20, minute: 0)
//        session4.endTime = makeDate(year: 2024, month: 7, day: 19, hour: 22, minute: 20)
//        session4.recurringDays.append(objectsIn: [.monday, .saturday])
//        
////        sessions = [session0, session1, session2, session3, session4]
//    }
//    
//    func create(session: Session) async throws {
//        sessions.append(session)
//    }
//    
//    func readAll() async throws -> [Session] {
//        return sessions
//    }
//    
//    func read(id: ObjectId) async throws -> Session? {
//        return sessions.first { $0._id == id }
//    }
//    
//    func update(session: Session) async throws {
//        if let index = sessions.firstIndex(where: { $0._id == session._id }) {
//            sessions[index] = session
//        }
//    }
//    
//    func delete(id: ObjectId) async throws {
//        if let index = sessions.firstIndex(where: { $0._id == id }) {
//            sessions.remove(at: index)
//        }
//    }
//}
