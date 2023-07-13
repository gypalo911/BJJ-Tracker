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
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension ProfileViewViewModel: ProfileViewViewAnalytics {
    func onProfileViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "profile_screen_viewed", metadata: [:]))
    }
}
