//
//  PersistanceManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.04.2023.
//

import CoreData

class PersistanceManager: ObservableObject {
    static let shared = PersistanceManager()
    
    static var preview: PersistanceManager = {
        let result = PersistanceManager(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<10 {
            let session = Session(context: viewContext)
            session.id = UUID()
            if i <= 5 {
//                session.startDate = Calendar.current.date(byAdding: .hour, value: i * 8, to: Date())
                session.startDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            } else {
                session.startDate = Calendar.current.date(byAdding: .day, value: i-(i - Int(i/2)), to: Date())
            }
            session.duration = Int16(120 - i)
            session.type = ActivityType.allCases.randomElement()?.rawValue
            session.style = GraplingStyle.gi.rawValue
            session.location = "Kyiv"
            session.notes = ((i % 2) != 0) ? "Useful links: https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/, https://bjj-world.com/best-martial-arts-for-self-defense/, https://bjj-world.com/caio-terra-ankle-lock-de-la-riva/, https://bjj-world.com/brazilian-jiu-jitsu-and-education-unleashing-the-power-of-mind-and-body/" : "https://blackbeltwiki.com/brazilian-jiu-jitsu. \n\n https://bjj-world.com/brazilian-jiu-jitsu-and-education-unleashing-the-power-of-mind-and-body/\n \n https://bjj-world.com/tom-hardy-promoted-to-purple-belt-in-jiu-jitsu/"

            let technique = TechniqueModel(context: viewContext)
            technique.id = UUID()
            technique.text = "\(i) technique"
            technique.addToSessions(session)
        }
        
        for i in 0..<1 {
            let model = PromotionModel(context: viewContext)
            model.id = UUID()
            model.belt = Int16(i)
            if i <= 5 {
                model.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            } else {
                model.date = Calendar.current.date(byAdding: .day, value: i-(i-1), to: Date())
            }
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
        #if !DEBUG
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        #endif
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch let error {
            print("\(error) while saving")
        }
    }
}
