//
//  PersistanceManager+Techniques.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

protocol TechniquesStorageManager {
    func fetchTechniques(for session: Session) -> [TechniqueModel]
    func fetchTechniquesForSuggestion() -> [TechniqueModel]
    func createTechnique(
        for session: Session,
        text: String,
        details: String?
    )
    func delete(model: TechniqueModel)
}

extension PersistanceManager: TechniquesStorageManager {
    func fetchTechniques(for session: Session) -> [TechniqueModel] {
        let fetchRequest: NSFetchRequest<TechniqueModel> = TechniqueModel.fetchRequest()
        
        do {
            let techniques = try container.viewContext.fetch(fetchRequest)
                .filter { $0.sessionsArray.contains(session) }
            
            return techniques
        } catch {
            print("Unable to Fetch techniques, (\(error))")
            return []
        }
    }
    
    func fetchTechniquesForSuggestion() -> [TechniqueModel] {
        let fetchRequest: NSFetchRequest<TechniqueModel> = TechniqueModel.fetchRequest()
        
        do {
            let techniques = try container.viewContext.fetch(fetchRequest)
                .sorted { $0.sessionsArray.count > $1.sessionsArray.count }
                .prefix(10)
            
            return Array(techniques)
        } catch {
            print("Unable to Fetch techniques, (\(error))")
            return []
        }
    }
    
    func createTechnique(
        for session: Session,
        text: String,
        details: String? = nil
    ) {
        let context = self.container.viewContext
        let model = TechniqueModel(context: context)
        model.update(with: text, details: details)
        model.addToSessions(session)
        
        save(context: context)
    }
    
    func delete(model: TechniqueModel) {
        let context = self.container.viewContext
        context.delete(model)
        
        save(context: context)
    }
}
