//
//  Calendar+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import Foundation

extension Calendar {
    var currentWeek: [WeekDay] {
        guard let firstWeekDay = self.dateInterval(of: .weekOfMonth, for: Date())?.start else {
            return []
        }
        var week: [WeekDay] = []
        for index in 0..<7 {
            if let day = self.date(byAdding: .day, value: index, to: firstWeekDay) {
                let weekDaySymbol = day.toString("EEE")
                let isToday = self.isDateInToday(day)
                week.append(.init(dayOfWeek: weekDaySymbol, date: day, isToday: isToday))
            }
        }
        return week
    }
    
    func week(for date: Date) -> [WeekDay] {
        guard let firstWeekDay = self.dateInterval(of: .weekOfMonth, for: date)?.start else {
            return []
        }
        var week: [WeekDay] = []
        for index in 0..<7 {
            if let day = self.date(byAdding: .day, value: index, to: firstWeekDay) {
                let weekDaySymbol = day.toString("EEE")
                let isToday = self.isDateInToday(day)
                week.append(.init(dayOfWeek: weekDaySymbol, date: day, isToday: isToday))
            }
        }
        return week
    }
    
    class WeekDay: Identifiable, Hashable {
        var id: UUID = .init()
        var dayOfWeek: String
        var date: Date
        var isToday: Bool = false
        
        init(dayOfWeek: String, date: Date, isToday: Bool) {
            self.dayOfWeek = dayOfWeek
            self.date = date
            self.isToday = isToday
        }
        
        static func == (lhs: Calendar.WeekDay, rhs: Calendar.WeekDay) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self).hashValue)
        }
    }
}
