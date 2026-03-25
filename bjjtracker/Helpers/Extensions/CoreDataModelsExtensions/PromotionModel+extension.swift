//
//  PromotionModel+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.05.2023.
//

import CoreData

extension PromotionModel {
    @objc
    var dateString: String {
        return Calendar.current.startOfDay(for: date ?? Date()).toString("dd MMMM yyyy")
    }
    
    func update(with promotion: Promotion) {
        id = promotion.id
        belt = Int16(promotion.belt.rawValue)
        stripes = Int16(promotion.stripes)
        date = promotion.date
        location = promotion.location
        notes = promotion.notes
    }
}

