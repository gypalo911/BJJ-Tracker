//
//  NotificationManagerProtocol.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation
import NotificationCenter

protocol NotificationManagerProtocol {
    var isAuthorized: Bool { get }
    var authrorizationStatus: UNAuthorizationStatus { get }
    func requestAuthorization(completion: @escaping  (Bool) -> Void)
    func scheduleNotification(activity: Activity)
    func removePendingNotificationRequests(with ids: [String])
}
