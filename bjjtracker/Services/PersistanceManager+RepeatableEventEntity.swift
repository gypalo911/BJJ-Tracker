//
//  PersistanceManager + RepeatableEventEntity.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.12.2025.
//

import CoreData

protocol RepeatableEventStorageManager {
    func createRepeatableEvent(id: String, from repeatableSettings: (any RepeatableSessionSettingsProtocol)?)
    func fetchRepeatableEvents() -> [RepeatableEventEntity]
    func repeatableEvent(by id: String) -> RepeatableEventEntity?
    func updateRepeatableEvent(id: String, repeatableSettings: any RepeatableSessionSettingsProtocol)
    func deleteRepeatableEvent(with id: String)
}

extension PersistanceManager: RepeatableEventStorageManager {
    func createRepeatableEvent(id: String, from repeatableSettings: (any RepeatableSessionSettingsProtocol)? = nil) {
        guard let repeatableSettings else { return }

        let context = self.container.viewContext
        let repeatableEvent = RepeatableEventEntity(context: context)
        repeatableEvent.update(id: id, settings: repeatableSettings)

        save(context: context)
    }

    func fetchRepeatableEvents() -> [RepeatableEventEntity] {
        let fetchRequest: NSFetchRequest<RepeatableEventEntity> = RepeatableEventEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        
        do {
            let events = try container.viewContext.fetch(fetchRequest)
            
            return events
        } catch {
            print("Unable to Fetch RepeatableEvents, (\(error))")
            return []
        }
    }

    func repeatableEvent(by id: String) -> RepeatableEventEntity? {
        let context = self.container.viewContext
        let events: NSFetchRequest<RepeatableEventEntity> = RepeatableEventEntity.fetchRequest()
        
        events.fetchLimit = 1
        let query = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        events.predicate = query
        
        do {
            let foundEntities: [RepeatableEventEntity] = try context.fetch(events)
            return foundEntities.first
        } catch {
            let fetchError = error as NSError
            debugPrint(fetchError)
        }
        
        return nil
    }

    func updateRepeatableEvent(id: String, repeatableSettings: any RepeatableSessionSettingsProtocol) {
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
