//
//  AddPromotionViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol AddPromotionViewAnalytics {
    func onScreenAppeared()
    func promotionCreated(_ promotion: Promotion)
}

class AddPromotionViewViewModel: ObservableObject {
    
    @Published var promotion: Promotion = .init(belt: .white, stripes: 0, date: Date(), location: "", notes: "")
    
    private let analyticsEngine: AnalyticsEngine
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension AddPromotionViewViewModel: AddPromotionViewAnalytics {
    func onScreenAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "add_promotion_screen_viewed", metadata: [:]))
    }
    
    func promotionCreated(_ promotion: Promotion) {
        analyticsEngine.log(AnalyticsEvent(
            name: "promotion_created",
            metadata: [
                "gradingSystem": promotion.gradingSystem.rawValue,
                "belt": promotion.belt.title,
                "stripes": "\(promotion.stripes)",
                "date": "\(promotion.date)"
            ]
        ))
    }
}
