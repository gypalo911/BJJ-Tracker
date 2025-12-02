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

class NewSessionViewViewModel: ObservableObject {
    
    @Published var recurringSettings: RecurringSettings = .init()
    @Published var isPickerPresented = false
    
    @Published var activity: Activity = .init(
        type: .training,
        style: .gi,
        duration: 60,
        startDate: Date(),
        location: "",
        notes: ""
    )
    
    private let persistanceManager: PersistanceManager
    private let notificationManager: NotificationManagerProtocol
    private let analyticsEngine: AnalyticsEngine
    
    init(
        persistanceManager: PersistanceManager,
        notificationManager: NotificationManagerProtocol = NotificationManager.shared,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()
    ) {
        self.persistanceManager = persistanceManager
        self.notificationManager = notificationManager
        self.analyticsEngine = analyticsEngine
    }
    
    func saveActivity() {
        if recurringSettings.isRepeatable {
            activity.repeatableId = UUID().uuidString
            save(activity)
            createRepeatedSessions()
        } else {
            save(activity)
        }
        
        sendSessionCreatedAnalytics(from: activity)
    }
    
    private func save(_ activity: Activity) {
        persistanceManager.createSession(from: activity)

        notificationManager.scheduleNotification(activity: activity)
    }
    
    private func createRepeatedSessions() {
        recurringSettings.generateOccurrences(from: activity.startDate).forEach { date in
            let tempActivity = activity
            tempActivity.startDate = date
            
            save(tempActivity)
        }
    }
}

extension NewSessionViewViewModel: NewSessionViewViewModelProtocol {
    func onAppear() {
        activity.startDate = AppSettings.shared.selectedCalendarDate

        if let selectedDay = DaysPicker.Day(rawValue: Date().dayNumberOfWeek() ?? 0), recurringSettings.selectedDays.isEmpty {
            recurringSettings.selectedDays = [selectedDay]
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
                "isRepeaTable": String(recurringSettings.isRepeatable),
                "repeatEndDate": recurringSettings.endDate.toString("dd MMM YYYY"),
                "numberOfRepeateSessions": recurringSettings.generateOccurrences(from: activity.startDate).count.stringValue
            ]
        ))
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
        static var repeatsEvery: String { "Repeats every:".localizedString }
        static var endCondition: String { "End condition".localizedString }

        // Duration and controls
        static var save: String { "Save".localizedString }

        // Form fields
        static var locationTitle: String { "Location:".localizedString }
        static var locationPlaceholder: String { "Location...".localizedString }
        static var notesTitle: String { "Notes".localizedString }
    }
}
