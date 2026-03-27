//
//  NewSessionViewModelTests.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation
import Testing
import UserNotifications
@testable import bjjtracker

@MainActor
struct NewSessionViewModelTests {
    // MARK: - Properties
    private let persistanceManager: MockSessionsStorageManager
    private let notificationManager: MockNotificationManager
    private let analyticsEngine: MockAnalyticsEngine
    private let appSettings: AppSettings

    // MARK: - Setup
    init() {
        persistanceManager = MockSessionsStorageManager()
        notificationManager = MockNotificationManager()
        analyticsEngine = MockAnalyticsEngine()
        appSettings = AppSettings()
    }

    // MARK: - Tests
    @Test
    func onAppearUsesInjectedSettingsAndLogsScreenView() {
        let selectedCalendarDate = makeDate(year: 2026, month: 1, day: 8, hour: 19)
        let currentDate = makeDate(year: 2026, month: 1, day: 5, hour: 8)
        let activity = makeActivity(startDate: makeDate(year: 2025, month: 12, day: 1, hour: 10))

        appSettings.selectedCalendarDate = selectedCalendarDate

        let sut = NewSessionViewViewModel(
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine,
            activity: activity,
            appSettings: appSettings,
            currentDate: { currentDate }
        )

        sut.onAppear()

        #expect(sut.activity.startDate == selectedCalendarDate)
        #expect(sut.repeatableSessionSettings.selectedDays == [.Monday])
        #expect(analyticsEngine.loggedEvent?.name == "new_session_screen_viewed")
    }

    @Test
    func onAppearKeepsExistingSelectedDays() {
        let currentDate = makeDate(year: 2026, month: 1, day: 5, hour: 8)
        let repeatableSettings = RepeatableSessionSettings()
        repeatableSettings.selectedDays = [.Wednesday]

        let sut = NewSessionViewViewModel(
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine,
            repeatableSessionSettings: repeatableSettings,
            appSettings: appSettings,
            currentDate: { currentDate }
        )

        sut.onAppear()

        #expect(sut.repeatableSessionSettings.selectedDays == [.Wednesday])
    }

    @Test
    func popupDismissedLogsDismissEvent() {
        let sut = NewSessionViewViewModel(
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine,
            appSettings: appSettings
        )

        sut.popupDismissed()

        #expect(analyticsEngine.loggedEvent?.name == "dismissed_new_session_screen")
    }

    @Test
    func saveActivityCreatesSingleSessionWhenNotRepeatable() {
        let startDate = makeDate(year: 2026, month: 1, day: 5, hour: 18)
        let activity = makeActivity(startDate: startDate)

        let sut = NewSessionViewViewModel(
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine,
            activity: activity,
            appSettings: appSettings
        )

        sut.saveActivity()

        #expect(persistanceManager.createdSessions.count == 1)
        #expect(persistanceManager.createdSessions.first?.activity.id == activity.id)
        #expect(persistanceManager.createdSessions.first?.activity.startDate == startDate)
        #expect(persistanceManager.createdSessions.first?.hasRepeatableSettings == false)
        #expect(notificationManager.scheduledActivities.count == 1)
        #expect(notificationManager.scheduledActivities.first?.id == activity.id)
        #expect(analyticsEngine.loggedEvent?.name == "session_created")
        #expect(analyticsEngine.loggedEvent?.metadata["isRepeaTable"] == "false")
        #expect(analyticsEngine.loggedEvent?.metadata["numberOfRepeateSessions"] == "1")
    }

    @Test
    func saveActivityCreatesRecurringSessionsAndSchedulesNotifications() {
        let firstDate = makeDate(year: 2026, month: 1, day: 5, hour: 18)
        let lastDate = makeDate(year: 2026, month: 1, day: 12, hour: 18)
        let activity = makeActivity(startDate: firstDate)
        let repeatableSettings = RepeatableSessionSettings()
        repeatableSettings.isRepeatable = true
        repeatableSettings.repeatType = .weekly
        repeatableSettings.repeatCondition = .every1Week
        repeatableSettings.selectedDays = [.Monday]
        repeatableSettings.endCondition = .onDate
        repeatableSettings.endDate = lastDate

        let sut = NewSessionViewViewModel(
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine,
            activity: activity,
            repeatableSessionSettings: repeatableSettings,
            appSettings: appSettings,
            repeatableIDGenerator: { "repeatable-id" }
        )

        sut.saveActivity()

        #expect(persistanceManager.createdSessions.count == 2)
        #expect(persistanceManager.createdSessions.map(\.activity.startDate) == [firstDate, lastDate])
        #expect(persistanceManager.createdSessions.map(\.activity.repeatableId) == ["repeatable-id", "repeatable-id"])
        #expect(persistanceManager.createdSessions.map(\.hasRepeatableSettings) == [true, false])
        #expect(notificationManager.scheduledActivities.count == 2)
        #expect(notificationManager.scheduledActivities.map(\.startDate) == [firstDate, lastDate])
        #expect(analyticsEngine.loggedEvent?.name == "session_created")
        #expect(analyticsEngine.loggedEvent?.metadata["isRepeaTable"] == "true")
        #expect(analyticsEngine.loggedEvent?.metadata["numberOfRepeateSessions"] == "2")
    }

    // MARK: - Helpers
    private func makeActivity(startDate: Date) -> Activity {
        Activity(
            id: UUID(uuidString: "12345678-1234-1234-1234-1234567890AB") ?? UUID(),
            type: .training,
            style: .gi,
            duration: 60,
            startDate: startDate,
            location: "Academy",
            notes: "Open mat"
        )
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0

        return components.date ?? Date()
    }
}
