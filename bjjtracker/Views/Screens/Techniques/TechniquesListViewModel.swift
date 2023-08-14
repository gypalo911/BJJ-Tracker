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
    @Published var rows: [[Tag]] = []
    @Published var tags: [Tag] = []
    @Published var suggestionTags: [Tag] = []
    @Published var tagText = ""
    
    // MARK: Regular variables
    var maxRowWidth: CGFloat = 0
    
    init(
        session: Session,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        persistanceManager: TechniquesStorageManager
    ) {
        self.session = session
        self.analyticsEngine = analyticsEngine
        self.persistanceManager = persistanceManager
    }
    
    // MARK: Functions
    func fetchTags() {
        let techniques = persistanceManager.fetchTechniques(for: session)
        techniques.forEach {
            tags.append(Tag(technique: $0, text: $0.text ?? ""))
        }
        let suggestions = persistanceManager.fetchTechniquesForSuggestion()
        suggestions.forEach { suggestion in
            if !techniques.map({ $0.text }).contains(suggestion.text) {
                suggestionTags.append(Tag(technique: suggestion, text: suggestion.text ?? ""))
            }
        }
        setupTagRows()
    }
    
    func add(tag: Tag) {
        if !tag.text.trimmingCharacters(in: .whitespaces).isEmpty {
            var newTag = tag
            newTag.type = .regular
            tags.append(newTag)
            removeSuggestionTag(tag)
            setupTagRows()
            
            persistanceManager.createTechnique(for: session, text: tag.text, details: nil)
            
            analyticsEngine.log(AnalyticsEvent(
                name: FirebaseAnalyticsEvent.tagAdded.rawValue,
                metadata: [
                    "tag_text":"\(tag.text)",
                    "tag_type":"\(tag.type.rawValue)"
                ]
            ))
        }
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
        suggestionTags = suggestionTags.filter{ $0.id != tag.id }
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
