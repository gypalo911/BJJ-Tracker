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
}

struct DateValue: Identifiable {
    var id: UUID = .init()
    var day: Int
    var date: Date
}

extension Int {
    func formatMinutes() -> (String, String) {
        return ("\(Int(self / 60))", "\(Int(self % 60))")
    }
}
