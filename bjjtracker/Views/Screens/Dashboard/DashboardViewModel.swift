////
////  DashboardViewModel.swift
////  bjjtracker
////
////  Created by Petro Hupalo on 17.05.2023.
////
//
import SwiftUI

enum ModalsSheets: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case activity
    case promotion
}

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var selectedSession: Session?
    
    @Published var selectedDay = Date()
    @Published var showingActionSheet: Bool = false
    @Published var selectedSheet: ModalsSheets?
    
    var currentWeek = Calendar.current.currentWeek
    
    var requestDateRange: DateInterval {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let rangeStart = lastWeekDate.first?.date ?? Date()
        let rangeEnd = currentWeek.last?.date ?? Date()
        return DateInterval(start: rangeStart, end: rangeEnd)
    }
    
    func selectModal(sheet: ModalsSheets) {
        selectedSheet = sheet
    }
    
    func select(session: Session) {
        selectedSession = session
    }
    
    func totalTime(_ sessions: [Session]) -> Int {
        return sessions.map { Int($0.duration) }.reduce(0, +)
    }
    
    func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDay)
    }
    
    func lastTwoWeeksSessions(_ sessions: [FetchedResults<Session>.Element]) -> ([Session], [Session]) {
        return (currentWeekSessions(sessions), lastWeekSessions(sessions))
    }
}

private extension DashboardViewModel {
    func currentWeekSessions(_ sessions: [FetchedResults<Session>.Element]) -> [Session] {
        let start = currentWeek.first?.date ?? Date()
        let end = currentWeek.last?.date ?? Date()
        return sessions.filter {
            (start...end).contains($0.startDate ?? Date())
        }
    }
    
    func lastWeekSessions(_ sessions: [FetchedResults<Session>.Element]) -> [Session] {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let start = lastWeekDate.first?.date ?? Date()
        let end = lastWeekDate.last?.date ?? Date()
        return sessions.filter {
            (start...end).contains($0.startDate ?? Date())
        }
    }
}
