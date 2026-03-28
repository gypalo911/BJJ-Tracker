//
//  PersistanceManager+Promotions.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

protocol PromotionsStorageManager {
    func fetchPromotions(in interval: DateInterval?) -> [PromotionModelEntity]
    func createPromotion(from promotion: Promotion, context: NSManagedObjectContext)
    func edit(model: PromotionModelEntity, promotion: Promotion, context: NSManagedObjectContext)
    func delete(model: PromotionModelEntity, context: NSManagedObjectContext)
}

extension PersistanceManager: PromotionsStorageManager {
    func fetchPromotions(in interval: DateInterval? = nil) -> [PromotionModelEntity] {
        let fetchRequest: NSFetchRequest<PromotionModelEntity> = PromotionModelEntity.fetchRequest()
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
        let model = PromotionModelEntity(context: context)
        model.update(with: promotion)
        
        save(context: context)
    }
    
    func edit(model: PromotionModelEntity, promotion: Promotion, context: NSManagedObjectContext) {
        model.update(with: promotion)
        
        save(context: context)
    }
    
    func delete(model: PromotionModelEntity, context: NSManagedObjectContext) {
        context.delete(model)
        
        save(context: context)
    }
}
