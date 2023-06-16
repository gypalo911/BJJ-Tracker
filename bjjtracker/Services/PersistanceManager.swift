//
//  PersistanceManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.04.2023.
//

import CoreData

protocol SessionsStorageManager {
    func session(by id: String, context: NSManagedObjectContext) -> Session?
    func createSession(from activity: Activity, context: NSManagedObjectContext)
    func edit(session: Session, activity: Activity, context: NSManagedObjectContext)
    func delete(session: Session, context: NSManagedObjectContext)
}

protocol PromotionsStorageManager {
    func createPromotion(from promotion: Promotion, context: NSManagedObjectContext)
    func edit(model: PromotionModel, promotion: Promotion, context: NSManagedObjectContext)
    func delete(model: PromotionModel, context: NSManagedObjectContext)
}

struct PersistanceManager {
    static let shared = PersistanceManager()
    
    static var preview: PersistanceManager = {
        let result = PersistanceManager(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<10 {
            let session = Session(context: viewContext)
            session.id = UUID()
            session.startDate = Calendar.current.date(byAdding: .hour, value: i * 8, to: Date())
            session.duration = Int16(120 - i)
            session.type = ActivityType.allCases.randomElement()?.rawValue
            session.style = GraplingStyle.gi.rawValue
            session.location = "Some Location"
            session.notes = "Some notes"
        }
        
        for i in 0..<10 {
            let model = PromotionModel(context: viewContext)
            model.id = UUID()
            model.belt = Int16(i)
            model.date = Calendar.current.date(byAdding: .hour, value: i * 8, to: Date())
            model.stripes = Int16.random(in: 0..<4)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("\(nsError)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "bjjtracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {}
    }
}

extension PersistanceManager: SessionsStorageManager {
    
    func session(by id: String, context: NSManagedObjectContext) -> Session? {
        let requestSessions: NSFetchRequest<Session> = Session.fetchRequest()
        
        // Make a predicate asking only for sessions of a certain "projectId"
        requestSessions.fetchLimit = 1
        let query = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        requestSessions.predicate = query
        
        // Perform the fetch with the predicate
        do {
            let foundEntities: [Session] = try context.fetch(requestSessions)
            return foundEntities.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }
    
    func createSession(from activity: Activity, context: NSManagedObjectContext) {
        let session = Session(context: context)
        session.update(with: activity)
        
        save(context: context)
    }
    
    func edit(session: Session, activity: Activity, context: NSManagedObjectContext) {
        session.update(with: activity)
        
        save(context: context)
    }
    
    func delete(session: Session, context: NSManagedObjectContext) {
        context.delete(session)
        
        save(context: context)
    }
}

extension PersistanceManager: PromotionsStorageManager {
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
