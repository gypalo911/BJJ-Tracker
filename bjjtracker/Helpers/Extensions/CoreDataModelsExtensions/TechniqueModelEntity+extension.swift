//
//  TechniqueModel+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import CoreData

extension TechniqueModel {
    public var sessionsArray: [SessionEntity] {
        let set = sessions as? Set<SessionEntity> ?? []
        return set.sorted {
            $0.startDate! < $1.startDate!
        }
    }
    
    func update(id: UUID = UUID(), with text: String, details: String?) {
        self.id = id
        self.text = text
        self.details = details
    }
}

