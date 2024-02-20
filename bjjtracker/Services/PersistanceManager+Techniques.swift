//
//  PersistanceManager+Techniques.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.07.2023.
//

import CoreData

protocol TechniquesStorageManager {
    func fetchAllTechniques() -> [TechniqueModel]
    func fetchTechniques(for session: Session) -> [TechniqueModel]
    func fetchTechniquesForSuggestion() -> [TechniqueModel]
    func createTechnique(
        for session: Session?,
        name: String,
        details: String
    )
    func addToSession(technique: TechniqueModel, _ session: Session)
    func delete(model: TechniqueModel)
}

extension PersistanceManager: TechniquesStorageManager {
    func fetchAllTechniques() -> [TechniqueModel] {
        let fetchRequest: NSFetchRequest<TechniqueModel> = TechniqueModel.fetchRequest()
        
        do {
            return try container.viewContext.fetch(fetchRequest)
                .sorted { $0.text ?? "" > $1.text ?? "" }
        } catch {
            print("Unable to Fetch techniques, (\(error))")
            return []
        }
    }
    
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
    
    func addToSession(technique: TechniqueModel, _ session: Session) {
        let context = self.container.viewContext
        technique.addToSessions(session)
        
        save(context: context)
    }
    
    func createTechnique(
        for session: Session? = nil,
        name: String,
        details: String
    ) {
        let context = self.container.viewContext
        let model = TechniqueModel(context: context)
        model.update(with: name, details: details)
        if let session = session {
            model.addToSessions(session)
        }
        
        save(context: context)
    }
    
    func edit(model: TechniqueModel, name: String, details: String) {
        let context = self.container.viewContext
        model.update(with: name, details: details)
        
        save(context: context)
    }
    
    func delete(by technique: Technique) {
        let techniques = fetchAllTechniques()
        if let model = techniques.first(where: {
            ($0.id ?? UUID()) == technique.id
        }) {
            delete(model: model)
        }
    }
    
    func delete(model: TechniqueModel) {
        let context = self.container.viewContext
        context.delete(model)
        
        save(context: context)
    }
}
