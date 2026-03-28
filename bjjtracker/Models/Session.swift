//
//  SessionEntity.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 28.03.2026.
//

import Foundation
import CoreData

struct Session: Equatable {
    let id: UUID?
    let repeatableId: String?
    let type: String?
    let style: String?
    let duration: Int
    let startDate: Date
    let location: String?
    let notes: String?
    
    init(from sessionEntity: SessionEntity) {
        self.id = sessionEntity.id
        self.repeatableId = sessionEntity.repeatableId
        self.type = sessionEntity.type
        self.style = sessionEntity.style
        self.duration = Int(sessionEntity.duration)
        self.startDate = sessionEntity.startDate ?? Date()
        self.location = sessionEntity.location
        self.notes = sessionEntity.notes
    }
}
