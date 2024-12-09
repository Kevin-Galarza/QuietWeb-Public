//
//  UNNotificationCategory.swift
//  QuietWeb
//
//  Created by Kevin Galarza on 8/5/24.
//

import UserNotifications

class Action {
    static let startAction = UNNotificationAction(identifier: "START_ACTION",
                                                  title: "Start Session",
                                                  options: [.foreground])
    
    static let endAction = UNNotificationAction(identifier: "END_ACTION",
                                                title: "End Session",
                                                options: [.foreground])
}

class Category {
    static let startCategory = UNNotificationCategory(identifier: "START_CATEGORY",
                                                      actions: [Action.startAction],
                                                      intentIdentifiers: [],
                                                      options: [])
    
    static let endCategory = UNNotificationCategory(identifier: "END_CATEGORY",
                                                      actions: [Action.endAction],
                                                      intentIdentifiers: [],
                                                      options: [])
}
