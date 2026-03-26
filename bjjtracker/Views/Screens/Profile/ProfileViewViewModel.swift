//
//  ProfileViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation

protocol ProfileViewViewAnalytics {
    var isHealthKitDataAuthorized: Bool { get }
    func onProfileViewAppeared()
}

class ProfileViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    private let persistanceManager: TechniquesStorageManager
    private let healthKitService: HealthKitService
    private let appReview: AppReviewProtocol
    
    @Published var techniques: [TechniqueModel] = []
    
    var isHealthKitDataAuthorized: Bool {
        healthKitService.isDataAuthorized
    }
    
    init(
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        persistanceManager: TechniquesStorageManager,
        healthKitService: HealthKitService,
        appReview: AppReviewProtocol
    ) {
        self.analyticsEngine = analyticsEngine
        self.persistanceManager = persistanceManager
        self.healthKitService = healthKitService
        self.appReview = appReview
    }
    
    // MARK: Functions
    func onAppear() {
        fetchTechniques()
        onProfileViewAppeared()
    }
    
    func fetchTechniques() {
        techniques = persistanceManager.fetchAllTechniques()
    }
    
    @MainActor
    func promptAppReview() {
        appReview.promptAppReview()
    }
}

extension ProfileViewViewModel: ProfileViewViewAnalytics {
    func onProfileViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "profile_screen_viewed", metadata: [:]))
    }
}
