//
//  PersistanceManager+Promotions.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

protocol PromotionsStorageManager {
    func fetchPromotions(in interval: DateInterval?) -> [PromotionModel]
    func createPromotion(from promotion: Promotion, context: NSManagedObjectContext)
    func edit(model: PromotionModel, promotion: Promotion, context: NSManagedObjectContext)
    func delete(model: PromotionModel, context: NSManagedObjectContext)
}

extension PersistanceManager: PromotionsStorageManager {
    func fetchPromotions(in interval: DateInterval? = nil) -> [PromotionModel] {
        let fetchRequest: NSFetchRequest<PromotionModel> = PromotionModel.fetchRequest()
        if let interval = interval {
            fetchRequest.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@",
                interval.start as CVarArg,
                interval.end as CVarArg
            )
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let promotions = try container.viewContext.fetch(fetchRequest)
            
            return promotions
        } catch {
            print("Unable to Fetch sessions, (\(error))")
            return []
        }
    }
    
    func createPromotion(from promotion: Promotion, context: NSManagedObjectContext) {
        let model = PromotionModel(context: context)
        model.update(with: promotion)
        
        save(context: context)
    }
    
    func edit(model: PromotionModel, promotion: Promotion, context: NSManagedObjectContext) {
        model.update(with: promotion)
        
        save(context: context)
    }
    
    func delete(model: PromotionModel, context: NSManagedObjectContext) {
        context.delete(model)
        
        save(context: context)
    }
}
