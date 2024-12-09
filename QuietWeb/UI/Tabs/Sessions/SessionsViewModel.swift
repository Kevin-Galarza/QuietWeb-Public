//
//  SessionsViewModel.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/10/24.
//

import Foundation
import Combine
import RealmSwift
import SafariServices

enum SessionsSectionType {
    case active
    case pending
    case upcoming
    case recurring
}

class SessionsViewModel {
    
    let sessionRepository: SessionRepository
    let blocklistRepository: BlocklistRepository
    let notificationScheduler: NotificationScheduler
    let sessionManager: SessionManager
    
    var categorizedSessions: [(sessionId: ObjectId, sessionSection: SessionsSectionType)] = []
    
    var availableSections: [SessionsSectionType] {
        let allSections: [SessionsSectionType] = [.active, .pending, .upcoming, .recurring]
        let sections = Set(categorizedSessions.map { $0.sessionSection })
        return allSections.filter { sections.contains($0) }
    }
    
    @Published var greeting: String = ""
    @Published var sessions: [Session] = []
    
    let presentSessionEditorPublisher = PassthroughSubject<SessionEditorPresentationMode, Never>()
    let refreshTableViewPublisher = PassthroughSubject<Void, Never>()
    let startSessionErrorPublisher = PassthroughSubject<Session, Never>()
    let confirmDeleteSessionPublisher = PassthroughSubject<Session, Never>()
    let hapticPublisher = PassthroughSubject<Void, Never>()
    
    init(sessionRepository: SessionRepository, blocklistRepository: BlocklistRepository, sessionManager: SessionManager, notificationScheduler: NotificationScheduler) {
        self.sessionRepository = sessionRepository
        self.blocklistRepository = blocklistRepository
        self.sessionManager = sessionManager
        self.notificationScheduler = notificationScheduler
        refresh()
    }
    
    // MARK: Refresh Data
    
    func refresh() {
        refreshGreeting()
        loadSessions()
    }
    
    func refreshGreeting() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        switch currentHour {
        case 0..<12:
            greeting = "Good Morning"
        case 12..<18:
            greeting = "Good Afternoon"
        default:
            greeting = "Good Evening"
        }
    }
    
    // MARK: Session Lifecycle
    
    func startSession(_ sessionId: ObjectId) {
        hapticPublisher.send()
        do {
            try sessionManager.startSession(sessionId)
            refresh()
        } catch {
            if case let SessionError.startError(session) = error {
                emitStartSessionError(session: session)
                print("Failed to start session: \(error)")
            }
        }
    }
    
    func endSession(_ sessionId: ObjectId) {
        hapticPublisher.send()
        do {
            try sessionManager.endSession(sessionId)
            refresh()
            ReviewManager.shared.incrementSessionCount()
            ReviewManager.shared.requestAppReviewIfAppropriate()
        } catch {
            print("Failed to end session: \(error)")
        }
    }
    
    func emitStartSessionError(session: Session) {
        startSessionErrorPublisher.send(session)
    }
    
    // MARK: Session CRUD
    
    private func loadSessions() {
        do {
            let sessions = try sessionRepository.readAll()
            self.sessions = sessions
            categorizedSessions = categorizeSessionsBySection(sessions: sessions)
            refreshTableViewPublisher.send()
        } catch {
            print("Failed to load blocklists: \(error)")
        }
    }
    
    func addSession() {
        presentSessionEditorPublisher.send(.create)
    }
    
    func editSession(_ session: Session) {
        presentSessionEditorPublisher.send(.edit(session: session))
    }
    
    func viewSession(_ session: Session) {
        presentSessionEditorPublisher.send(.view(session: session))
    }
    
    func confirmDeleteSession(sessionId: ObjectId) {
        guard let session = sessions.first(where: { $0._id == sessionId }) else { return }
        confirmDeleteSessionPublisher.send(session)
    }
    
    func deleteSession(sessionId: ObjectId) {
        do {
            try sessionRepository.delete(id: sessionId)
            notificationScheduler.removeNotification(for: sessionId)
            refresh()
        } catch {
            print("Failed to delete session: \(error)")
        }
    }
    
    // MARK: Helper Methods
    
    func remainingTime(_ session: Session) -> String {
        let now = Date()
        let calendar = Calendar.current

        if session.type == .recurring {
            // Get the current hour and minute
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            let endHour = calendar.component(.hour, from: session.endTime)
            let endMinute = calendar.component(.minute, from: session.endTime)
            
            // Calculate the remaining time in minutes
            let endTotalMinutes = endHour * 60 + endMinute
            let currentTotalMinutes = currentHour * 60 + currentMinute
            
            // Handle the case where the end time is past midnight
            let remainingMinutes = endTotalMinutes >= currentTotalMinutes ? endTotalMinutes - currentTotalMinutes : (24 * 60) - currentTotalMinutes + endTotalMinutes
            
            let hours = remainingMinutes / 60
            let minutes = remainingMinutes % 60
            
            return "\(hours)H \(minutes)M"
        } else {
            // Calculate the remaining time in seconds
            let remainingTimeInterval = session.endTime.timeIntervalSince(now)
            if remainingTimeInterval <= 0 {
                return "Expired"
            }
            
            let hours = Int(remainingTimeInterval) / 3600
            let minutes = (Int(remainingTimeInterval) % 3600) / 60
            
            return "\(hours)H \(minutes)M"
        }
    }
    
    func sessionIsReadyToExpire(_ session: Session) -> Bool {
        let now = Date()
        
        if session.type == .recurring {
            // Extract the current hour and minute
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: now)
            let currentMinute = calendar.component(.minute, from: now)
            
            let endHour = calendar.component(.hour, from: session.endTime)
            let endMinute = calendar.component(.minute, from: session.endTime)
            
            // Check if the current time is past the session's end time
            let isPastEndTime = currentHour > endHour || (currentHour == endHour && currentMinute >= endMinute)
            return isPastEndTime
        } else {
            return now > session.endTime
        }
    }
    
    func formattedUpcomingSubtitle(for session: Session) -> String {
        guard session.type == .later else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
        
        let formattedDate = dateFormatter.string(from: session.startTime)
        return "Begins \(formattedDate)"
    }
    
    func formattedRecurringSubtitle(for session: Session) -> String {
        guard session.type == .recurring else { return "" }
        
        // Get recurring days
        let daysSet = Set(session.recurringDays)
        let weekdaysSet: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekendSet: Set<Weekday> = [.saturday, .sunday]
        let allDaysSet: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        
        let daysString: String
        if daysSet == allDaysSet {
            daysString = "Everyday"
        } else if daysSet == weekdaysSet {
            daysString = "Weekdays"
        } else if daysSet == weekendSet {
            daysString = "Weekends"
        } else if daysSet.count == 1 {
            daysString = daysSet.first?.description ?? ""
        } else {
            // Sort the days starting from Sunday to Saturday
            let sortedDays = session.recurringDays.sorted { $0.rawValue < $1.rawValue }
            daysString = sortedDays.map { $0.shortName }.joined(separator: "-")
        }
        
        // Format start and end time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mma"
        
        let calendar = Calendar.current
        
        let startHour = calendar.component(.hour, from: session.startTime)
        let startMinute = calendar.component(.minute, from: session.startTime)
        let endHour = calendar.component(.hour, from: session.endTime)
        let endMinute = calendar.component(.minute, from: session.endTime)
        
        let startTimeComponents = DateComponents(hour: startHour, minute: startMinute)
        let endTimeComponents = DateComponents(hour: endHour, minute: endMinute)
        
        let startTime = calendar.date(from: startTimeComponents)!
        let endTime = calendar.date(from: endTimeComponents)!
        
        let startTimeString = timeFormatter.string(from: startTime)
        let endTimeString = timeFormatter.string(from: endTime)
        
        return "Repeats \(daysString), \(startTimeString)-\(endTimeString)"
    }
    
    private func categorizeSessionsBySection(sessions: [Session]) -> [(sessionId: ObjectId, sessionSection: SessionsSectionType)] {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentWeekday = Weekday(rawValue: calendar.component(.weekday, from: now)) ?? .sunday
        
        var categorizedSessions: [(sessionId: ObjectId, sessionSection: SessionsSectionType)] = []
        
        let activeSessions = sessions.filter { $0.isActive }
        activeSessions.forEach { categorizedSessions.append((sessionId: $0._id, sessionSection: .active))}
        
        let pendingSessions = sessions.filter { session in
            let calendar = Calendar.current
            let startHour = calendar.component(.hour, from: session.startTime)
            let startMinute = calendar.component(.minute, from: session.startTime)
            let endHour = calendar.component(.hour, from: session.endTime)
            let endMinute = calendar.component(.minute, from: session.endTime)
            
            if session.type == .recurring {
                let isWithinTimeRange = (currentHour > startHour || (currentHour == startHour && currentMinute >= startMinute))
                    && (currentHour < endHour || (currentHour == endHour && currentMinute <= endMinute))
                return !session.isActive && session.recurringDays.contains(currentWeekday) && isWithinTimeRange
            } else {
                let isPending = now >= session.startTime && now <= session.endTime
                return isPending && !session.isActive
            }
        }
        pendingSessions.forEach { categorizedSessions.append((sessionId: $0._id, sessionSection: .pending)) }
        
        let upcomingSections = sessions.filter { session in
            return session.type == .later && session.startTime > now
        }
        upcomingSections.forEach { categorizedSessions.append((sessionId: $0._id, sessionSection: .upcoming))}
        
        let recurringSessions = sessions.filter { session in
            let calendar = Calendar.current
            let startHour = calendar.component(.hour, from: session.startTime)
            let startMinute = calendar.component(.minute, from: session.startTime)
            let endHour = calendar.component(.hour, from: session.endTime)
            let endMinute = calendar.component(.minute, from: session.endTime)
            
            let isWithinTimeRange = currentHour > startHour || (currentHour == startHour && currentMinute >= startMinute)
                && (currentHour < endHour || (currentHour == endHour && currentMinute <= endMinute))
            return session.type == .recurring && !session.isActive && (!isWithinTimeRange || !session.recurringDays.contains(currentWeekday))
        }
        recurringSessions.forEach { categorizedSessions.append((sessionId: $0._id, sessionSection: .recurring))}
        
        return categorizedSessions
    }
}

extension SessionsViewModel: SessionEditorResponder {
    func didCreateSession(_ session: Session) {
        if session.type == .now {
            do {
                try sessionManager.startSession(session._id)
            } catch {
                print("error starting .now session: \(error)")
            }
        } else {
            notificationScheduler.scheduleNotification(for: session, type: .reminder)
        }
        refresh()
    }
    
    func didModifySession(_ session: Session) {
        notificationScheduler.updateNotification(for: session)
        refresh()
    }
}
