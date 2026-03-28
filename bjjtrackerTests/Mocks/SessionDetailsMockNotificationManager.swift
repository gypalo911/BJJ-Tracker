//
//  SessionDetailsMockNotificationManager.swift
//  bjjtrackerTests
//
//  Created by OpenAI on 27.03.2026.
//

import Foundation
import UserNotifications
@testable import bjjtracker

final class SessionDetailsMockNotificationManager: NotificationManagerProtocol {
    let isAuthorized = true
    let authrorizationStatus: UNAuthorizationStatus = .authorized

    private(set) var removedPendingNotificationRequestIDs: [String] = []

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func scheduleNotification(activity: Activity) {}

    func removePendingNotificationRequests(with ids: [String]) {
        removedPendingNotificationRequestIDs.append(contentsOf: ids)
    }
}
