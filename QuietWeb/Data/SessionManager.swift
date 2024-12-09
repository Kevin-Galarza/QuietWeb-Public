//
//  SessionManager.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/7/24.
//

import Foundation
import RealmSwift

enum SessionError: Error {
    case startError(session: Session)
}

class SessionManager {
    
    let sessionRepository: SessionRepository
    let notificationScheduler: NotificationScheduler
    let blocklistCoordinator: BlocklistCoordinator
    
    init(sessionRepository: SessionRepository, notificationScheduler: NotificationScheduler, blocklistCoordinator: BlocklistCoordinator) {
        self.sessionRepository = sessionRepository
        self.notificationScheduler = notificationScheduler
        self.blocklistCoordinator = blocklistCoordinator
    }
    
    func startSession(_ sessionId: ObjectId) throws {
        guard let session = try sessionRepository.read(id: sessionId) else { return }
        guard sessionIsReady(session: session) else {
            throw(SessionError.startError(session: session))
        }
        try sessionRepository.update(session: session, isActive: true)
        notificationScheduler.scheduleNotification(for: session, type: .completion)
        blocklistCoordinator.handleBlocklistUpdate(for: .distractions)
    }
    
    func endSession(_ sessionId: ObjectId) throws {
        try sessionRepository.delete(id: sessionId)
        blocklistCoordinator.handleBlocklistUpdate(for: .distractions)
    }
    
    private func sessionIsReady(session: Session) -> Bool {
        return !session.blocklists.isEmpty && (session.endTime > Date())
    }
}
