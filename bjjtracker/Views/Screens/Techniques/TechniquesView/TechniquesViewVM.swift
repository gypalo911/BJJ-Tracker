//
//  TechniquesViewVM.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.02.2024.
//

import Foundation
import CoreData

enum SortingType: String, CaseIterable, Identifiable {
    case name
//    case createdAt
    case updatedAt
    var id: Self { return self }
    
    var title: String {
        switch self {
        case .name:
            return "Name".localizedString
//        case .createdAt:
//            return "Newest".localizedString
        case .updatedAt:
            return "Updated recently".localizedString
        }
    }
}

class TechniquesViewVM: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    private let persistanceManager: TechniquesStorageManager
    
    // MARK: @Published variables
    @Published var isHeaderHidden = false
    @Published var isEmptySearchStateState = true
    @Published var isShowingTechniqueDetails = false
    @Published var isModifyingTechnique = false
    @Published var isEditing = false
    @Published var searchText = ""
    @Published var selectedTechnique: TechniqueModel?
    
    @Published var sortingType: SortingType = .name
    
    @Published var results: [TechniqueModel] = []
    
    var filteredResults: [TechniqueModel] {
        var result: [TechniqueModel] = []
        if searchText.isEmpty {
            result = results
        } else {
            result = results.filter {
                ($0.text ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.details ?? "").lowercased().contains(searchText.lowercased())
            }
        }
        
        switch(sortingType) {
        case .name:
            result = result.filter { $0.text != nil }.sorted(by: { $0.text! < $1.text! })
            break
//        case .createdAt:
//            result = result.sorted(by: {
//                ($0.createdAt ?? Date()) > ($1.createdAt ?? Date())
//            })
//            break
        case .updatedAt:
            result = result.sorted(by: { $0.updatedAt > $1.updatedAt })
            break
        }
        
        return result
    }
    
    var suggestions: [String] {
        return results.filter {
            $0.text != nil &&
            $0.text!.lowercased().contains(searchText.lowercased())
        }
        .prefix(5).map { $0.text! }
    }
    
    // MARK: Regular variables
    var maxRowWidth: CGFloat = 0
    
    init(
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        persistanceManager: TechniquesStorageManager
    ) {
        self.analyticsEngine = analyticsEngine
        self.persistanceManager = persistanceManager
    }
    
    // MARK: Functions
    func fetchTechniques() {
        let techniques = persistanceManager.fetchAllTechniques()
        results = techniques
    }
}

// MARK: Private extension
private extension TechniquesViewVM {
    
}
