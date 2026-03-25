//
//  PersistanceManager + RepeatableEvent.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.12.2025.
//

import CoreData

protocol RepeatableEventStorageManager {
    func createRepeatableEvent(id: String, from repeatableSettings: RepeatableSessionSettings?)
    func fetchRepeatableEvents() -> [RepeatableEvent]
    func repeatableEvent(by id: String) -> RepeatableEvent?
    func updateRepeatableEvent(id: String, repeatableSettings: RepeatableSessionSettings)
    func deleteRepeatableEvent(with id: String)
}

extension PersistanceManager: RepeatableEventStorageManager {
    func createRepeatableEvent(id: String, from repeatableSettings: RepeatableSessionSettings? = nil) {
        guard let repeatableSettings else { return }

        let context = self.container.viewContext
        let repeatableEvent = RepeatableEvent(context: context)
        repeatableEvent.update(id: id, settings: repeatableSettings)

        save(context: context)
    }

    func fetchRepeatableEvents() -> [RepeatableEvent] {
        let fetchRequest: NSFetchRequest<RepeatableEvent> = RepeatableEvent.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        
        do {
            let events = try container.viewContext.fetch(fetchRequest)
            
            return events
        } catch {
            print("Unable to Fetch RepeatableEvents, (\(error))")
            return []
        }
    }

    func repeatableEvent(by id: String) -> RepeatableEvent? {
        let context = self.container.viewContext
        let events: NSFetchRequest<RepeatableEvent> = RepeatableEvent.fetchRequest()
        
        events.fetchLimit = 1
        let query = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        events.predicate = query
        
        do {
            let foundEntities: [RepeatableEvent] = try context.fetch(events)
            return foundEntities.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }

    func updateRepeatableEvent(id: String, repeatableSettings: RepeatableSessionSettings) {
        guard let repeatableEvent = repeatableEvent(by: id) else {
            return
        }
        let context = self.container.viewContext
        repeatableEvent.update(id: id, settings: repeatableSettings)
        
        save(context: context)
    }

    func deleteRepeatableEvent(with id: String) {
        guard let event = repeatableEvent(by: id) else { return }

        let context = self.container.viewContext
        context.delete(event)
        
        save(context: context)
    }
}
