//
//  SessionEntity+Extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import CoreData

extension SessionEntity {
    @objc
    var startDateString: String {
        return Calendar.current.startOfDay(for: startDate ?? Date()).toString("dd MMMM yyyy")
    }
    
    func update(with activity: Activity) {
        id = activity.id
        repeatableId = activity.repeatableId
        type = activity.type.rawValue
        style = activity.style.rawValue
        duration = Int16(activity.duration)
        startDate = activity.startDate
        location = activity.location
        notes = activity.notes
    }
}
