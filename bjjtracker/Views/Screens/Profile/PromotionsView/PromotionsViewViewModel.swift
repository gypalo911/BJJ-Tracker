//
//  PromotionsViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 03.08.2023.
//

import Foundation

class PromotionsViewViewModel: ObservableObject {
    
    typealias StorageManager = PromotionsStorageManager
    
    // MARK: Variables
    private let persistanceManager: StorageManager
    
    @Published var gradingSystem: GradingSystem
    @Published var promotionModels: [PromotionModelEntity] = []
    
    var promotions: [Promotion] {
        promotionModels.map {
            Promotion.from($0)
        }
    }
    
    var lastPromotion: Promotion? {
        let belts = Belt.belts(for: gradingSystem)
        return promotions
            .filter {
                belts.contains($0.belt)
            }
            .sorted(by: {
                $0.belt.rawValue == $1.belt.rawValue ? ($0.stripes < $1.stripes) :
                ($0.belt.rawValue < $1.belt.rawValue)
            }).last
    }
    
    var beltsArray: [Belt] {
        Belt.belts(for: gradingSystem).filter { $0 != .none }
    }
    
    init(persistanceManager: StorageManager, gradingSystem: GradingSystem) {
        self.persistanceManager = persistanceManager
        self.gradingSystem = gradingSystem
    }
    
    // MARK: Functions
    func setup() {
        fetchPromotions()
    }
    
    // MARK: Private functions
    private func fetchPromotions(in interval: DateInterval? = nil) {
        let fetchedPromotions = persistanceManager.fetchPromotions(in: interval)
        promotionModels = fetchedPromotions
    }
}
