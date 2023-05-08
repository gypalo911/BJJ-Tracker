//
//  Session+Extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import CoreData

extension Session {
    @objc
    var startDateString: String {
        return Calendar.current.startOfDay(for: startDate!).toString("dd MMMM YYYY")
    }
    
    func update(with activity: Activity) {
        id = activity.id
        type = activity.type.rawValue
        style = activity.style.rawValue
        duration = Int16(activity.duration)
        startDate = activity.startDate
        location = activity.location
        notes = activity.notes
    }
}
