//
//  PersistanceManager+Sessions.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

protocol SessionsStorageManager {
    func fetchSessions(in interval: DateInterval?) -> [Session]
    func session(by id: String) -> Session?
    func createSession(from activity: ActivityModel)
    func edit(session: Session, activity: ActivityModel)
    func delete(session: Session)
}

extension PersistanceManager: SessionsStorageManager {
    
    func fetchSessions(in interval: DateInterval? = nil) -> [Session] {
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        if let interval = interval {
            fetchRequest.predicate = NSPredicate(
                format: "startDate >= %@ AND startDate <= %@",
                interval.start as CVarArg,
                interval.end as CVarArg
            )
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            let sessions = try container.viewContext.fetch(fetchRequest)
            
            return sessions
        } catch {
            print("Unable to Fetch sessions, (\(error))")
            return []
        }
    }
    
    func session(by id: String) -> Session? {
        let context = self.container.viewContext
        let requestSessions: NSFetchRequest<Session> = Session.fetchRequest()
        
        requestSessions.fetchLimit = 1
        let query = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        requestSessions.predicate = query
        
        do {
            let foundEntities: [Session] = try context.fetch(requestSessions)
            return foundEntities.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }
    
    func createSession(from activity: ActivityModel) {
        let context = self.container.viewContext
        let session = Session(context: context)
        session.update(with: activity)
        DefaultHealthKitService().store(session: session)
        
        save(context: context)
    }
    
    func edit(session: Session, activity: ActivityModel) {
        let context = self.container.viewContext
        session.update(with: activity)
        
        save(context: context)
    }
    
    func delete(session: Session) {
        let context = self.container.viewContext
        DefaultHealthKitService().delete(session: session)
        context.delete(session)
        
        save(context: context)
    }
}
