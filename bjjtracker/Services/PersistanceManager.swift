//
//  PersistanceManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.04.2023.
//

import CoreData

struct PersistanceManager {
    static let shared = PersistanceManager()
    
    static var preview: PersistanceManager = {
        let result = PersistanceManager(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<10 {
            let session = Session(context: viewContext)
            session.id = UUID()
            session.startDate = Date()
            session.duration = Int16(120 - i)
            session.type = ActivityType.seminar.rawValue
            session.style = GraplingStyle.gi.rawValue
            session.location = "Some Location"
            session.notes = "Some notes"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("\(nsError)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "bjjtracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved \(error), \(error.userInfo)")
            }
        })
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved!")
        } catch {
            print("Couldn't save")
        }
    }
    
    func createSession(from activity: Activity, context: NSManagedObjectContext) {
        var session = Session(context: context)
        session.update(with: activity)
        
        save(context: context)
    }
    
    func edit(session: Session, activity: Activity, context: NSManagedObjectContext) {
        session.update(with: activity)
        
        save(context: context)
    }
}
