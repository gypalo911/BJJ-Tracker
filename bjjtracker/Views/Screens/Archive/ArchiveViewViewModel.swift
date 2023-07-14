//
//  ArchiveViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol ArchiveViewAnalytics {
    func onArchiveViewAppeared()
    func createSessionButtonTapped()
    func addPromotionButtonTapped()
}

class ArchiveViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension ArchiveViewViewModel: ArchiveViewAnalytics {
    func onArchiveViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "archive_screen_viewed", metadata: [:]))
    }
    
    func createSessionButtonTapped() {
        analyticsEngine.log(AnalyticsEvent(name: "create_session_button_tapped", metadata: [:]))
    }
    
    func addPromotionButtonTapped() {
        analyticsEngine.log(AnalyticsEvent(name: "add_promotion_button_tapped", metadata: [:]))
    }
}
