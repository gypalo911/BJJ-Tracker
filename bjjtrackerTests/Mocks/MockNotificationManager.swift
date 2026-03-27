//
//  MockNotificationManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 27.03.2026.
//

import Foundation
import UserNotifications

final class MockNotificationManager: NotificationManagerProtocol {
    let isAuthorized = true
    let authrorizationStatus: UNAuthorizationStatus = .authorized

    private(set) var scheduledActivities: [Activity] = []

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func scheduleNotification(activity: Activity) {
        scheduledActivities.append(activity)
    }

    func removePendingNotificationRequests(with ids: [String]) {}
}
