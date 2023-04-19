//
//  CoreDataService.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import CoreData

protocol ActivitiesStoraging {
    func save(_ activity: Activity) throws
    func update(_ activity: Activity) throws
    func deleteActivity(with id: UUID) throws
}

protocol ActivitiesReading {
    func fetchAllActivities() throws -> [Activity]
    func fetchActivities(from dateInterval: DateInterval) throws -> [Activity]
    func fetchActivity(by id: UUID) throws -> Activity?
}

class CoreDataService: ObservableObject, ActivitiesStoraging, ActivitiesReading {
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "bjjtracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func save(_ activity: Activity) throws {
        let moc = storeContainer.viewContext
        let session = Session(context: moc)
        session.update(with: activity)

        try moc.save()
    }
    
    func update(_ activity: Activity) throws {
        let moc = storeContainer.viewContext
        let fetchRequest = Session.fetchRequest()
        let sessions = try moc.fetch(fetchRequest)
        guard let session = sessions.first(where: {
            if let id = $0.id {
              return id == activity.id
            }
            return false
        }) else {
            return
        }
        session.update(with: activity)
        
        try moc.save()
    }

    func fetchAllActivities() throws -> [Activity] {
        let moc = storeContainer.viewContext
        let request = Session.fetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let sessions = try moc.fetch(request)
            var activities: [Activity] = []
            for session in sessions {
                if let activity = Activity.from(session: session) {
                    activities.append(activity)
                }
            }
            return activities
        } catch {
            print("Fetch failed")
        }
        return []
    }
    
    func fetchActivities(from dateInterval: DateInterval) throws -> [Activity] {
        let moc = storeContainer.viewContext
        let request = Session.fetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            let sessions = try moc.fetch(request)
            var activities: [Activity] = []
            for session in sessions {
                if let startDate = session.startDate,
                   startDate >= dateInterval.start,
                   startDate <= dateInterval.end,
                   let activity = Activity.from(session: session)
                {
                    activities.append(activity)
                }
            }
            return activities
        } catch {
            print("Fetch failed")
        }
        return []
    }
    
    func fetchActivity(by id: UUID) throws -> Activity? {
        let moc = storeContainer.viewContext
        let fetchRequest = Session.fetchRequest()
        let sessions = try moc.fetch(fetchRequest)
        guard let session = sessions.first(where: { $0.id == id }) else {
            return nil
        }
        return Activity.from(session: session)
    }
    
    func deleteActivity(with id: UUID) throws {
        let moc = storeContainer.viewContext
        let fetchRequest = Session.fetchRequest()
        let sessions = try moc.fetch(fetchRequest)
        if let session = sessions.first(where: { $0.id == id }) {
            moc.delete(session)
            
            try moc.save()
        }
    }
}
