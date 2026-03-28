////
////  DashboardViewModel.swift
////  bjjtracker
////
////  Created by Petro Hupalo on 17.05.2023.
////
//
import SwiftUI
import HealthKit

struct HealthData {
    var totalEnergyBurned: Double = 0
    var workoutsCount: Int = 0
}

@MainActor
class DashboardViewModel: ObservableObject {
    private let analyticsEngine: AnalyticsEngine
    private let healthKitService: HealthKitService
    
    @Published var selectedSession: SessionEntity? = nil
    
    @Published var selectedDay = Date()
    @Published var selectedSheet: ModalSheets? = nil
    
    var currentWeek = Calendar.current.currentWeek
    
    @Published var healthData: HealthData = HealthData()
    
    var requestDateRange: DateInterval {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let rangeStart = lastWeekDate.first?.date ?? Date()
        let sunday = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 7, to: sunday) ?? Date()
        return DateInterval(start: rangeStart, end: rangeEnd)
    }
    
    init(
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        healthKitService: HealthKitService = DefaultHealthKitService()
    ) {
        self.analyticsEngine = analyticsEngine
        self.healthKitService = healthKitService
    }
    
    func selectModal(sheet: ModalSheets) {
        selectedSheet = sheet
        switch sheet {
        case .activity:
            selectedModal("activity")
        case .promotion:
            selectedModal("promotion")
        }
    }
    
    func select(session: SessionEntity) {
        selectedSession = session
    }
    
    func totalTime(_ sessions: [SessionEntity]) -> Int {
        return sessions.map { Int($0.duration) }.reduce(0, +)
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDay)
    }
    
    func lastTwoWeeksSessions(_ sessions: [FetchedResults<SessionEntity>.Element]) -> ([SessionEntity], [SessionEntity]) {
        return (currentWeekSessions(sessions), lastWeekSessions(sessions))
    }
}

private extension DashboardViewModel {
    func currentWeekSessions(_ sessions: [FetchedResults<SessionEntity>.Element]) -> [SessionEntity] {
        let currentWeek = Calendar.current.week(for: Date().startOfDay)
        let start = currentWeek.first?.date ?? Date()
        let end = currentWeek.last?.date ?? Date()
        return sessions.filter {
            (start...end).contains(($0.startDate ?? Date()).startOfDay)
        }
    }
    
    func lastWeekSessions(_ sessions: [FetchedResults<SessionEntity>.Element]) -> [SessionEntity] {
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

extension DashboardViewModel {
    func onDashboardAppeared() {
        setupHealthData()
        analyticsEngine.log(AnalyticsEvent(name: "dashboard_screen_viewed", metadata: [:]))
    }

    func selectedModal(_ modalName: String) {
        analyticsEngine.log(AnalyticsEvent(name: "\(modalName)_from_dashboard_selected", metadata: [:]))
    }
}
