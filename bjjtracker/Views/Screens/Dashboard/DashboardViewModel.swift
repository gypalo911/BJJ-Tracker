////
////  DashboardViewModel.swift
////  bjjtracker
////
////  Created by Petro Hupalo on 17.05.2023.
////
//
import SwiftUI
import HealthKit
import Combine

struct HealthData {
    var totalEnergyBurned: Double = 0
    var workoutsCount: Int = 0
}

@MainActor
class DashboardViewModel: ObservableObject {
    typealias StorageManager = SessionsStorageManager & PromotionsStorageManager & TechniquesStorageManager

    enum Localisation {
        static var dashboard: String { "Dashboard".localizedString }
        static var viewHistory: String { "View History".localizedString }
        static var emptyDay: String { "No sessions for this day".localizedString }
        static var caloriesBurned: String { "%@ calories burned" }
        static var sessions: String { "Sessions".localizedString }
        static var totalTime: String { "Total time".localizedString }
    }

    private let persistanceManager: StorageManager
    private let appSettings: AppSettings
    private let analyticsEngine: AnalyticsEngine
    private let healthKitService: HealthKitService
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var sessions: [SessionEntity] = []
    @Published var selectedSession: SessionEntity? = nil
    
    @Published var selectedDay = Date()
    @Published private(set) var isTabBarHidden: Bool = false
    
    var currentWeek = Calendar.current.currentWeek
    
    @Published var healthData: HealthData = HealthData()
    
    var requestDateRange: DateInterval {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let rangeStart = lastWeekDate.first?.date ?? Date()
        let sunday = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 7, to: sunday) ?? Date()
        return DateInterval(start: rangeStart, end: rangeEnd)
    }

    var filteredSessions: [SessionEntity] {
        sessions.filter {
            isDateSelected($0.startDate ?? Date())
        }
    }
    
    init(
        persistanceManager: StorageManager,
        appSettings: AppSettings = .shared,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        healthKitService: HealthKitService = DefaultHealthKitService()
    ) {
        self.persistanceManager = persistanceManager
        self.appSettings = appSettings
        self.analyticsEngine = analyticsEngine
        self.healthKitService = healthKitService
        self.selectedDay = appSettings.selectedCalendarDate
        self.isTabBarHidden = appSettings.isTabBarHidden

        bindAppSettings()
    }

    func select(session: SessionEntity) {
        selectedSession = session
    }
    
    func fetchSessions() {
        sessions = persistanceManager.fetchSessions(in: requestDateRange)
    }
    
    func totalTime(_ sessions: [SessionEntity]) -> Int {
        return sessions.map { Int($0.duration) }.reduce(0, +)
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDay)
    }
    
    func lastTwoWeeksSessions(_ sessions: [SessionEntity]) -> ([SessionEntity], [SessionEntity]) {
        return (currentWeekSessions(sessions), lastWeekSessions(sessions))
    }

    func createButtonTapped() {
        appSettings.showingActionSheet = true
    }

    func selectedDayChanged(to value: Date) {
        appSettings.selectedCalendarDate = value.setCurrentTime()
        setupHealthData()
    }

    func connectAppleHealthTapped() {
        appSettings.isTabBarHidden = true
    }

    func connectAppleHealthPresentationChanged(isPresented: Bool) {
        appSettings.isTabBarHidden = isPresented
    }

    func onDashboardAppeared() {
        appSettings.isTabBarHidden = false
        selectedDay = appSettings.selectedCalendarDate
        fetchSessions()
        setupHealthData()
        analyticsEngine.log(AnalyticsEvent(name: "dashboard_screen_viewed", metadata: [:]))
    }

    func didDismissSelectedSession() {
        selectedSession = nil
        fetchSessions()
        appSettings.isTabBarHidden = false
    }

    func makeJournalViewModel() -> JournalViewViewModel {
        JournalViewViewModel(persistanceManager: persistanceManager)
    }

    func makeSessionDetailsViewModel(
        for session: SessionEntity,
        dismissCallback: (() -> Void)? = nil
    ) -> SessionDetailsViewModel {
        SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: NotificationManager(),
            dismissCallback: dismissCallback
        )
    }
}

private extension DashboardViewModel {
    func bindAppSettings() {
        appSettings.$selectedSheet
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                if value == nil {
                    self?.fetchSessions()
                }
            }
            .store(in: &cancellables)

        appSettings.$isTabBarHidden
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isTabBarHidden = value
            }
            .store(in: &cancellables)

        appSettings.$navigateToPage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] id in
                self?.openSession(with: id)
            }
            .store(in: &cancellables)
    }

    func openSession(with id: String) {
        guard let session = persistanceManager.session(by: id) else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.selectedSession = session
        }
    }

    func currentWeekSessions(_ sessions: [SessionEntity]) -> [SessionEntity] {
        let currentWeek = Calendar.current.week(for: Date().startOfDay)
        let start = currentWeek.first?.date ?? Date()
        let end = currentWeek.last?.date ?? Date()
        return sessions.filter {
            (start...end).contains(($0.startDate ?? Date()).startOfDay)
        }
    }
    
    func lastWeekSessions(_ sessions: [SessionEntity]) -> [SessionEntity] {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let start = lastWeekDate.first?.date ?? Date()
        let end = lastWeekDate.last?.date ?? Date()
        return sessions.filter {
            (start...end).contains(($0.startDate ?? Date()).startOfDay)
        }
    }
}

// MARK: HealthKit
extension DashboardViewModel {
    var isHealthKitAuthorized: Bool {
        return healthKitService.isDataAuthorized
    }
    
    func authorizeHealthKitIfNeeded(completion: (() -> Void)?) {
        healthKitService.authorizeHealthKitIfNeeded { _ in
            completion?()
        }
    }
    
    func fetchEnergyForSelectedDay() async {
        let dateInterval = DateInterval(start: selectedDay.startOfDay, end: selectedDay.endOfDay)
        let result = await healthKitService.energyStatisticsValue(
            dateInterval: dateInterval,
            calculation: .sum
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            healthData.totalEnergyBurned = result
        }
    }
    
    func fetchWorkoutsCount() async {
        let dateInterval = DateInterval(start: selectedDay.startOfDay, end: selectedDay.endOfDay)
        let result = await healthKitService.workoutsCount(dateInterval: dateInterval)
        withAnimation(.easeInOut(duration: 0.25).delay(0.1)) {
            healthData.workoutsCount = result
        }
    }
    
    func setupHealthData() {
        Task {
            await fetchEnergyForSelectedDay()
            await fetchWorkoutsCount()
        }
    }
}
