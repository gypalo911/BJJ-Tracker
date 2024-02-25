//
//  TechniquesListViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.07.2023.
//

import Foundation
import CoreData

class TechniquesListViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    private let persistanceManager: TechniquesStorageManager
    private let session: Session
    
    // MARK: @Published variables
    @Published var allTechniques: [TechniqueModel] = []
    @Published var rows: [[Tag]] = []
    @Published var tags: [Tag] = []
    
    var suggestionTags: [Tag] {
        return allTechniques
            .filter { tec in
                !tags.map { $0.text }.contains(where: { $0 == tec.text })
            }
            .filter {
                $0.text != nil &&
                $0.text!.lowercased().contains(creationalTag.text.lowercased())
            }
            .prefix(5)
            .map {
                Tag(text: $0.text ?? "")
            }
    }
    @Published var creationalTag: Tag = .init(text: "")
    
    // MARK: Regular variables
    var maxRowWidth: CGFloat = 0
    var onTechniqueDetails: ((TechniqueModel?) -> Void)?
    
    init(
        session: Session,
        allTechniques: [TechniqueModel] = [],
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        persistanceManager: TechniquesStorageManager,
        onTechniqueDetails: ((TechniqueModel?) -> Void)?
    ) {
        self.session = session
        self.allTechniques = allTechniques
        self.analyticsEngine = analyticsEngine
        self.persistanceManager = persistanceManager
        self.onTechniqueDetails = onTechniqueDetails
    }
    
    // MARK: Functions
    func fetchTags() {
        tags = []
        
        allTechniques = persistanceManager.fetchAllTechniques()
        let techniques = persistanceManager.fetchTechniques(for: session)
        techniques.forEach {
            tags.append(Tag(technique: $0, text: $0.text ?? ""))
        }
        setupTagRows()
    }
    
    func add(tag: Tag) {
        guard !tag.text.trimmingCharacters(in: .whitespaces).isEmpty &&
                !tags.contains(where: {
                    $0.text.lowercased() == tag.text.lowercased()
                }) else {
            return
        }
        
        var newTag = tag
        newTag.type = .regular
        tags.append(newTag)
        removeSuggestionTag(tag)
        
        creationalTag = .init(text: "")
        
        if let technique = allTechniques.first(where: {
            $0.text?.lowercased() == newTag.text.lowercased()
        }) {
            persistanceManager.addToSession(technique: technique, session)
            fetchTags()
            return
        }
        
        _ = persistanceManager.createTechnique(for: session, name: tag.text, details: "")
        fetchTags()
        
        analyticsEngine.log(AnalyticsEvent(
            name: FirebaseAnalyticsEvent.tagAdded.rawValue,
            metadata: [
                "tag_text":"\(tag.text)",
                "tag_type":"\(tag.type.rawValue)"
            ]
        ))
        analyticsEngine.log(AnalyticsEvent(name: "Tag wasn't added because it was empty", metadata: [:]))
    }
    
    func removeRegularTag(_ tag: Tag) {
        tags = tags.filter{ $0.id != tag.id }
        setupTagRows()
        
        if let technique = tag.technique {
            persistanceManager.delete(model: technique)
        }
        
        analyticsEngine.log(AnalyticsEvent(
            name: "tag_removed",
            metadata: [
                "tag_text":"\(tag.text)",
                "tag_type":"\(tag.type.rawValue)"
            ]
        ))
    }
    
    func removeSuggestionTag(_ tag: Tag) {
//        suggestionTags = suggestionTags.filter{ $0.id != tag.id }
    }
    
    func getIndex(tag: Tag) -> Int {
        let index = tags.firstIndex { currentTag in
            return tag.id == currentTag.id
        } ?? 0
        return index
    }
    
    func setupTagRows() {
        var rows: [[Tag]] = []
        var currentRow: [Tag] = []
        var totalWidth: CGFloat = 0
        let tagSpacing: CGFloat = 20 /*Leading & Trailing 10, 10 Spacing*/
        
        if !tags.isEmpty{
            for index in 0..<tags.count{
                self.tags[index].size = tags[index].text.textSize().width + 25
            }
            
            tags.forEach { tag in
                totalWidth += (tag.size + tagSpacing)
                
                if totalWidth > self.maxRowWidth {
                    totalWidth = !currentRow.isEmpty || rows.isEmpty ? (tag.size + 40) : 0
                    
                    rows.append(currentRow)
                    currentRow.removeAll()
                    currentRow.append(tag)
                } else {
                    currentRow.append(tag)
                }
            }
            
            if !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow.removeAll()
            }
            
            self.rows = rows
        } else {
            self.rows = []
        }
        
        
    }
}

// MARK: Private extension
private extension TechniquesListViewModel {
    
}
