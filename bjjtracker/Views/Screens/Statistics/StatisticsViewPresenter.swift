//
//  StatisticsViewPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct StatisticsViewPresenter {
    let persistanceManager: ActivitiesReading = CoreDataService()
    
    var title: String = ""
    var isConcreteDates: Bool = false
    var previousPeriod: DateInterval
    
    @State var dateInterval: DateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
    
    init(dateInterval: DateInterval) {
        self.previousPeriod = DateInterval(start: dateInterval.start - dateInterval.duration, end: dateInterval.start)
    }
    
    mutating func update(dateInterval: DateInterval) {
        self.dateInterval = dateInterval
    }
}

extension StatisticsViewPresenter {
    func intervalToString(from: Date, to: Date, segment: Int) -> String {
        if segment == 0 {
            if from.isSame(as: to, by: [.day, .month, .year]) {
                return "\(to.toString("dd MMMM yyyy"))"
            } else if from.isSame(as: to, by: [.year]) {
                return "\(from.toString("dd MMMM"))-\(to.toString("dd MMMM yyyy"))"
            } else if Calendar.current.isDate(from, inSameDayAs: from.startOfMonth()) && Calendar.current.isDate(from, inSameDayAs: from.endOfMonth()) {
                return "\(to.toString("LLLL yyyy").capitalized)"
            } else {
                return "\(from.toString("dd MMMM yyyy"))-\(to.toString("dd MMMM yyyy"))"
            }
        } else if segment == 1 {
            return to.toString("LLLL yyyy").capitalized
        } else {
            return to.toString("yyyy")
        }
    }
}
