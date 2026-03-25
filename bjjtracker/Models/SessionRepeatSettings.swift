//
//  SessionRepeatSettings.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 02.12.2025.
//

import Foundation

enum RepeatType: Int, CaseIterable, Identifiable {
    case weekly
    case monthly
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .weekly:
            "Weekly".localizedString
        case .monthly:
            "Monthly".localizedString
        }
    }
}

enum RepeatCondition: Int, CaseIterable, Identifiable {
    case every1Week
    case every2Weeks
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .every1Week:
            "Every Week".localizedString
        case .every2Weeks:
            "Every 2 Weeks".localizedString
        }
    }
    
    var weekIntValue: Int {
        self == .every1Week ? 1 : 2
    }
}

enum EndCondition: Int, CaseIterable, Identifiable {
    case never
    case onDate
    
    var id: Int { self.rawValue }
    
    var title: String {
        switch self {
        case .never:
            "Never".localizedString
        case .onDate:
            "On date".localizedString
        }
    }
}


class RepeatableSessionSettings: ObservableObject {
    @Published var isRepeatable: Bool = false
    @Published var repeatType: RepeatType = .weekly
    @Published var repeatCondition: RepeatCondition = .every1Week
    @Published var selectedDays: [DaysPicker.Day] = []
    @Published var endCondition: EndCondition = .never
    @Published var endDate: Date = Date().addingTimeInterval(TimeInterval(3600*24*7))
    
    var summaryDescription: String {
        guard isRepeatable else { return "Does not repeat".localizedString }

        switch repeatType {
        case .weekly:
            let interval: String = repeatCondition.title

            let dayTitles = selectedDays
                .sorted { $0.rawValue < $1.rawValue }
                .map { $0.localizedTitle }
                .joined(separator: ", ")

            let base = dayTitles.isEmpty ? interval : interval + " on " + dayTitles

            switch endCondition {
            case .never:
                return base
            case .onDate:
                let formattedDate = endDate.formatted(.dateTime.year().month(.wide).day())
                return base + " until " + formattedDate
            }

        case .monthly:
            let base = "Every month".localizedString
            switch endCondition {
            case .never:
                return base
            case .onDate:
                let formattedDate = endDate.formatted(.dateTime.year().month(.wide).day())
                return base + " until " + formattedDate
            }
        }
    }

    func sessionsCountDescription(from firstSessionDate: Date) -> String {
        let occurrences = generateOccurrences(from: firstSessionDate)
        let count = occurrences.count
        
        guard count > 1 else { return "1 session will be created" }
        
        let base = "\(count) " + (count == 1 ? "session" : "sessions")
        return "\(base) will be created"
    }
    
    /// For the "Next sessions:" list in the blue box.
    func nextSessionsPreview(
        from firstSessionDate: Date,
        maxPreview: Int = 5,
        calendar: Calendar = .current
    ) -> [Date] {
        let occurrences = generateOccurrences(from: firstSessionDate, calendar: calendar)
        // We already know [0] is the first session itself; usually preview wants from the second one
        return Array(occurrences.dropFirst().prefix(maxPreview))
    }
}

extension RepeatableSessionSettings {
    /// Generate all occurrences for given start date.
    /// - Parameters:
    ///   - firstSessionDate: date/time of the first session created by user.
    ///   - calendar: calendar to use for calculations.
    ///   - maxOccurrencesForNever: safety cap when `endCondition == .never`.
    func generateOccurrences(
        from firstSessionDate: Date,
        calendar: Calendar = .current,
        maxOccurrencesForNever: Int = 100
    ) -> [Date] {
        guard isRepeatable else { return [firstSessionDate] }
        
        switch repeatType {
        case .weekly:
            return generateWeeklyOccurrences(
                from: firstSessionDate,
                calendar: calendar,
                maxOccurrencesForNever: maxOccurrencesForNever
            )
            
        case .monthly:
            return generateMonthlyOccurrences(
                from: firstSessionDate,
                calendar: calendar,
                maxOccurrencesForNever: maxOccurrencesForNever
            )
        }
    }
    
    // MARK: - Weekly
    
    private func generateWeeklyOccurrences(
        from firstSessionDate: Date,
        calendar: Calendar,
        maxOccurrencesForNever: Int
    ) -> [Date] {
        var results: [Date] = []
        
        // Time-of-day for all generated sessions
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: firstSessionDate)
        
        // Start from week that contains firstSessionDate
        var currentWeekStart = calendar.date(from: calendar.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: firstSessionDate
        ))!
        
        // If user didn't pick days – fallback to weekday of firstSessionDate
        let weekdays: [Int] = {
            if selectedDays.isEmpty {
                return [calendar.component(.weekday, from: firstSessionDate)]
            } else {
                return selectedDays.map { $0.rawValue }.sorted()
            }
        }()
        
        func reachedEnd(afterAdding candidate: Date) -> Bool {
            switch endCondition {
            case .never:
                return results.count >= maxOccurrencesForNever
            case .onDate:
                return candidate > endDate
            }
        }
        
        outer: while true {
            for weekday in weekdays {
                var comps = calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: currentWeekStart
                )
                comps.weekday = weekday
                comps.hour   = timeComponents.hour
                comps.minute = timeComponents.minute
                comps.second = timeComponents.second
                
                guard let candidate = calendar.date(from: comps) else { continue }
                
                // Don't add dates before the first session
                guard candidate >= firstSessionDate else { continue }
                
                // For `.onDate` – stop once candidate is beyond endDate
                if case .onDate = endCondition, candidate > endDate {
                    break outer
                }
                
                results.append(candidate)
                
                if reachedEnd(afterAdding: candidate) {
                    break outer
                }
            }
            
            // Jump N weeks forward
            guard let nextWeekStart = calendar.date(
                byAdding: .weekOfYear,
                value: repeatCondition.weekIntValue,
                to: currentWeekStart
            ) else { break }
            
            currentWeekStart = nextWeekStart
        }
        
        return results
    }
    
    // MARK: - Monthly
    
    private func generateMonthlyOccurrences(
        from firstSessionDate: Date,
        calendar: Calendar,
        maxOccurrencesForNever: Int
    ) -> [Date] {
        var results: [Date] = []
        var current = firstSessionDate
        
        func shouldStop(for candidate: Date) -> Bool {
            switch endCondition {
            case .never:
                return results.count >= maxOccurrencesForNever
            case .onDate:
                return candidate > endDate
            }
        }
        
        while true {
            if case .onDate = endCondition, current > endDate {
                break
            }
            
            results.append(current)
            
            if shouldStop(for: current) { break }
            
            guard let next = calendar.date(byAdding: .month, value: 1, to: current) else { break }
            current = next
        }
        
        return results
    }
}
