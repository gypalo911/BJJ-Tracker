//
//  NotificationManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 16.06.2023.
//

import NotificationCenter

struct NotificationManager {
    
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _  in
            completion(granted)
        }
    }
    
    func scheduleNotification(activity: Activity) {
        let content = UNMutableNotificationContent()
        content.title = "\(activity.style.rawValue.localizedString) \(activity.type.rawValue.localizedString)"
        content.body = "Starts at %@".localized(with: ["\((activity.startDate).toString("HH:mm"))"])
        
        let notificationDate = activity.startDate.addingTimeInterval(TimeInterval(-AppSettings.shared.notificationTime))
        if notificationDate <= Date() {
            return
        }
        let components = Calendar.current.dateComponents([.year,.day,.month,.hour,.minute,.second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: String(describing: activity.id),
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func removePendingNotificationRequests(with ids: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
