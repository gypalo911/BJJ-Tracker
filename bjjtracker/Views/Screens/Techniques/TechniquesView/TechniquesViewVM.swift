//
//  TechniquesViewVM.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.02.2024.
//

import Foundation
import CoreData

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
    
    @Published var results: [TechniqueModel] = []
    
    var filteredResults: [TechniqueModel] {
        if searchText.isEmpty {
            return results
        }
        return results.filter {
            ($0.text ?? "").lowercased().contains(searchText.lowercased()) ||
            ($0.details ?? "").lowercased().contains(searchText.lowercased())
        }
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
