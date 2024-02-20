//
//  ProfileViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation

protocol ProfileViewViewAnalytics {
    func onProfileViewAppeared()
}

class ProfileViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    private let persistanceManager: TechniquesStorageManager
    
    @Published var techniques: [TechniqueModel] = []
    
    init(
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        persistanceManager: TechniquesStorageManager
    ) {
        self.analyticsEngine = analyticsEngine
        self.persistanceManager = persistanceManager
    }
    
    // MARK: Functions
    func onAppear() {
        fetchTechniques()
        onProfileViewAppeared()
    }
    
    func fetchTechniques() {
        techniques = persistanceManager.fetchAllTechniques()
    }
}

extension ProfileViewViewModel: ProfileViewViewAnalytics {
    func onProfileViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "profile_screen_viewed", metadata: [:]))
    }
}
