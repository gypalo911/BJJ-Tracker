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
                week.append(.init(string: weekDaySymbol, date: day, isToday: isToday))
            }
        }
        return week
    }
    
    class WeekDay: Identifiable {
        var id: UUID = .init()
        var string: String
        var date: Date
        var isToday: Bool = false
        
        init(string: String, date: Date, isToday: Bool) {
            self.string = string
            self.date = date
            self.isToday = isToday
        }
    }
}
