//
//  TechniqueModel+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import CoreData

extension TechniqueModel {
    public var sessionsArray: [Session] {
        let set = sessions as? Set<Session> ?? []
        return set.sorted {
            $0.startDate! < $1.startDate!
        }
    }
    
    func update(with text: String, details: String?) {
        self.text = text
        self.details = details
    }
}

