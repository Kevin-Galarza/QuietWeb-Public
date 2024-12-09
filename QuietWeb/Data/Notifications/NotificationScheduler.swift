//
//  NotificationScheduler.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/7/24.
//

import RealmSwift
import UserNotifications

// for push scheduling we need the following depending on session type:
// for .now send a single completion push once the session duration has elapsed
// for .later send a reminder push at the start time and completion push after session duration
// for .recurring send a reminder push at start time and completion push at end time, recurring on recurringDays

class NotificationScheduler {
    
    enum NotificationType {
        case reminder
        case completion
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func scheduleNotification(for session: Session, type: NotificationType) {
        switch session.type {
        case .now:
            scheduleNowNotification(session: session, type: type)
        case .later:
            scheduleLaterNotification(session: session, type: type)
        case .recurring:
            scheduleRecurringNotification(session: session, type: type)
        case .none:
            break
        }
    }
    
    private func scheduleNowNotification(session: Session, type: NotificationType) {
        if type == .completion { scheduleCompletionNotification(session: session, date: session.endTime) }
    }
    
    private func scheduleLaterNotification(session: Session, type: NotificationType) {
        if type == .reminder { scheduleReminderNotification(session: session, date: session.startTime) }
        if type == .completion { scheduleCompletionNotification(session: session, date: session.endTime) }
    }
    
    private func scheduleRecurringNotification(session: Session, type: NotificationType) {
        for day in session.recurringDays {
            if type == .reminder { scheduleReminderNotification(session: session, date: session.startTime, recurringDay: day) }
            if type == .completion { scheduleCompletionNotification(session: session, date: session.endTime, recurringDay: day) }
        }
    }
    
    private func scheduleReminderNotification(session: Session, date: Date, recurringDay: Weekday? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Your session \(session.name) is starting."
        content.sound = .default
        content.categoryIdentifier = "START_CATEGORY"
        content.userInfo = ["sessionId" : session._id.stringValue]
        
        let trigger: UNNotificationTrigger
        if let recurringDay = recurringDay {
            trigger = createWeeklyTrigger(date: date, weekday: recurringDay)
        } else {
            trigger = createTrigger(date: date)
        }
        
        let request = UNNotificationRequest(identifier: "\(session._id)-reminder", content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: nil)
    }
    
    private func scheduleCompletionNotification(session: Session, date: Date, recurringDay: Weekday? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "Your session \(session.name) is complete."
        content.sound = .default
        content.categoryIdentifier = "END_CATEGORY"
        content.userInfo = ["sessionId" : session._id.stringValue]
        
        let trigger: UNNotificationTrigger
        if let recurringDay = recurringDay {
            trigger = createWeeklyTrigger(date: date, weekday: recurringDay)
        } else {
            trigger = createTrigger(date: date)
        }
        
        let request = UNNotificationRequest(identifier: "\(session._id)-completion", content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: nil)
    }
    
    private func createTrigger(date: Date) -> UNCalendarNotificationTrigger {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    private func createWeeklyTrigger(date: Date, weekday: Weekday) -> UNCalendarNotificationTrigger {
        var components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        components.weekday = weekday.rawValue
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
    
    func updateNotification(for session: Session) {
        // Remove existing notifications for this session
        removeNotification(for: session._id)
        
        // Schedule new notifications
        if session.type == .now {
            scheduleNotification(for: session, type: .completion)
        } else {
            scheduleNotification(for: session, type: .reminder)
        }
        
    }
    
    func removeNotification(for sessionId: ObjectId) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(sessionId)-reminder"])
    }
}
