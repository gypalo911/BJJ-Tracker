//
//  PersistanceManager+Sessions.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

extension PersistanceManager: SessionsStorageManager {
    
    // MARK: - Create
    
    func createSession(from activity: Activity, repeatableSettings: (any RepeatableSessionSettingsProtocol)? = nil) {
        let context = self.container.viewContext
        let session = SessionEntity(context: context)
        session.update(with: activity)
        
        save(context: context)
        
        if let repeatableId = activity.repeatableId, let repeatableSettings {
            createRepeatableEvent(id: repeatableId, from: repeatableSettings)
        }
    }
    
    // MARK: - Read
    
    func fetchSessions(in interval: DateInterval? = nil) -> [SessionEntity] {
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
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
    
    func session(by id: String) -> SessionEntity? {
        let context = self.container.viewContext
        let requestSessions: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        
        requestSessions.fetchLimit = 1
        let query = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        requestSessions.predicate = query
        
        do {
            let foundEntities: [SessionEntity] = try context.fetch(requestSessions)
            return foundEntities.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }
    
    func sessions(with repeatableId: String) -> [SessionEntity] {
        let context = self.container.viewContext
        let requestSessions: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        
        let query = NSPredicate(format: "%K == %@", "repeatableId", repeatableId as CVarArg)
        requestSessions.predicate = query
        
        do {
            let foundEntities: [SessionEntity] = try context.fetch(requestSessions)
            return foundEntities
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return []
    }
    
    // MARK: - Update
    
    func update(session: SessionEntity, activity: Activity) {
        let context = self.container.viewContext
        session.update(with: activity)
                
        save(context: context)
    }
    
    // MARK: - Delete
    
    func delete(session: SessionEntity) {
        let context = self.container.viewContext

        context.delete(session)
        
        save(context: context)
    }
    
    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType) {
        var sessions = sessions(with: repeatableId)

        if case .future(let afterDate) = type, let afterDate {
            sessions = sessions.filter({
                guard let startDate = $0.startDate else { return false }
                return startDate > afterDate
            })
        }

        sessions.forEach {
            delete(session: $0)
        }
    }
}
