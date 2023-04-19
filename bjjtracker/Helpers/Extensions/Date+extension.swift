//
//  Date+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import Foundation

extension Date {
    func toString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func allDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            return calendar.date(
                byAdding: .day,
                value: day - 1,
                to: startDate
            )!
        }
    }
    
    func isSame(as date: Date, by components: Set<Calendar.Component>) -> Bool {
        let date1 = Calendar.current.dateComponents(components, from: self)
        let date2 = Calendar.current.dateComponents(components, from: date)
        
        return date1 == date2
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

struct DateValue: Identifiable {
    var id: UUID = .init()
    var day: Int
    var date: Date
}

extension Int {
    func minutesToDuration() -> String {
        var str = ""
        let hours = Int(self / 60)
        let minutes = Int(self % 60)
        if hours != 0 {
            str += "\(hours)h "
        }
        str += "\(minutes)min"
        return str
    }
}
