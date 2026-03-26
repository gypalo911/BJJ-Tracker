//
//  NewSessionViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol NewSessionViewViewModelProtocol {
    func saveActivity()
    func onAppear()
    func popupDismissed()
}

@MainActor
class NewSessionViewViewModel: ObservableObject {
    
    @Published var repeatableSessionSettings: RepeatableSessionSettings
    @Published var isPickerPresented = false
    
    @Published var activity: Activity
    
    private let persistanceManager: SessionsStorageManager
    private let notificationManager: NotificationManagerProtocol?
    private let analyticsEngine: AnalyticsEngine
    private let appSettings: AppSettings
    private let currentDate: () -> Date
    private let repeatableIDGenerator: () -> String
    
    init(
        persistanceManager: SessionsStorageManager,
        notificationManager: NotificationManagerProtocol? = nil,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        activity: Activity = .init(
            type: .training,
            style: .gi,
            duration: 60,
            startDate: Date(),
            location: "",
            notes: ""
        ),
        repeatableSessionSettings: RepeatableSessionSettings = .init(),
        appSettings: AppSettings = AppSettings.shared,
        currentDate: @escaping () -> Date = Date.init,
        repeatableIDGenerator: @escaping () -> String = { UUID().uuidString }
    ) {
        self.persistanceManager = persistanceManager
        self.notificationManager = notificationManager
        self.analyticsEngine = analyticsEngine
        self.activity = activity
        self.repeatableSessionSettings = repeatableSessionSettings
        self.appSettings = appSettings
        self.currentDate = currentDate
        self.repeatableIDGenerator = repeatableIDGenerator
    }
    
    func saveActivity() {
        if repeatableSessionSettings.isRepeatable {
            activity.repeatableId = repeatableIDGenerator()
            save(activity.copy(), repeatableSettings: repeatableSessionSettings)
            createRepeatedSessions()
        } else {
            save(activity.copy())
        }
        
        sendSessionCreatedAnalytics(from: activity)
    }
    
    private func save(_ activity: Activity, repeatableSettings: RepeatableSessionSettings? = nil) {
        persistanceManager.createSession(from: activity, repeatableSettings: repeatableSettings)

        notificationManager?.scheduleNotification(activity: activity)
    }
    
    private func createRepeatedSessions() {
        repeatableSessionSettings
            .generateOccurrences(from: activity.startDate)
            .dropFirst()
            .forEach { date in
                save(activity.copy(startDate: date))
        }
    }
}

extension NewSessionViewViewModel: @MainActor NewSessionViewViewModelProtocol {
    func onAppear() {
        activity.startDate = appSettings.selectedCalendarDate

        if let selectedDay = DaysPicker.Day(rawValue: currentDate().dayNumberOfWeek() ?? 0),
           repeatableSessionSettings.selectedDays.isEmpty {
            repeatableSessionSettings.selectedDays = [selectedDay]
        }
        analyticsEngine.log(AnalyticsEvent(name: "new_session_screen_viewed", metadata: [:]))
    }
    
    func popupDismissed() {
        analyticsEngine.log(AnalyticsEvent(name: "dismissed_new_session_screen", metadata: [:]))
    }
    
    private func sendSessionCreatedAnalytics(from activity: Activity) {
        analyticsEngine.log(AnalyticsEvent(
            name: "session_created",
            metadata: [
                "id": activity.id.uuidString,
                "type": activity.type.rawValue,
                "style": activity.style.rawValue,
                "startDate": activity.startDate.toString("dd MMMM yyyy"),
                "duration": "\(activity.duration)",
                "status": activity.status.rawValue,
                "location": activity.location,
                "notes": activity.notes,
                "isRepeaTable": String(repeatableSessionSettings.isRepeatable),
                "repeatEndDate": repeatableSessionSettings.endDate.toString("dd MMM YYYY"),
                "numberOfRepeateSessions": repeatableSessionSettings.generateOccurrences(from: activity.startDate).count.stringValue
            ]
        ))
    }
}

private extension Activity {
    func copy(startDate targetStartDate: Date? = nil, repeatableID targetRepeatableID: String? = nil) -> Activity {
        Activity(
            id: id,
            repeatableId: targetRepeatableID ?? repeatableId,
            type: type,
            style: style,
            duration: duration,
            startDate: targetStartDate ?? startDate,
            location: location,
            notes: notes
        )
    }
}

extension NewSessionViewViewModel {
    enum Localisation {
        static var newSession: String { "New Session".localizedString }

        // Step titles
        static var step1SelectType: String { "1. " + "Select type:".localizedString }
        static var step2SelectGrapplingStyle: String { "2. " + "Select grappling style:".localizedString }
        static var step3Duration: String { "3. " + "Duration:".localizedString }
        static var step4SelectDateAndTime: String { "4. " + "Select date and time:".localizedString }

        // Recurring/Repeat section
        static var repeatSession: String { "Repeat session".localizedString }
        static var recurringSectionTitle: String { "Recurring".localizedString }
        static var recurringPickerTitle: String { "Recurring options".localizedString }
        static var repeatConditionPickerTitle: String { "Repeat condition".localizedString }
        static var repeatsEvery: String { "Repeats every:".localizedString }
        static var endCondition: String { "End condition".localizedString }
        static var endConditionPickerTitle: String { "End condition options".localizedString }

        // Duration and controls
        static var save: String { "Save".localizedString }

        // Form fields
        static var locationTitle: String { "Location:".localizedString }
        static var locationPlaceholder: String { "Location...".localizedString }
        static var notesTitle: String { "Notes".localizedString }
    }
}
