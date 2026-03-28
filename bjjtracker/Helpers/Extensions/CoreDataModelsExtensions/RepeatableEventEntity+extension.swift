//
//  RepeatableEventEntity+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.12.2025.
//

import CoreData

extension RepeatableEventEntity {
    func update(id: String, settings: any RepeatableSessionSettingsProtocol) {
        self.id = id
        self.repeatType = Int16(settings.repeatType.rawValue)
        self.repeatCondition = Int16(settings.repeatCondition.rawValue)
        self.endCondition = Int16(settings.endCondition.rawValue)
        self.endDate = settings.endDate
    }
}
