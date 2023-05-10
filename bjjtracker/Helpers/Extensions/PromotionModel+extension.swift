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
        return Calendar.current.startOfDay(for: date ?? Date()).toString("dd MMMM YYYY")
    }
    
    func update(with promotion: Promotion) {
        id = promotion.id
        adultBelt = promotion.adultBelt.rawValue
        juniorBelt = promotion.juniorBelt.rawValue
        stripes = Int16(promotion.stripes)
        date = promotion.date
        location = promotion.location
        notes = promotion.notes
    }
    
    var index: Int {
        guard let adultBelt = adultBelt,
              let juniorBelt = juniorBelt else {
            return 0
        }
        return adultBelt != "none" ? AdultBelts(rawValue: adultBelt)!.index : JuniorBelts(rawValue: juniorBelt)!.index
    }
}

