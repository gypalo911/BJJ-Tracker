//
//  TimetableViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation

protocol TimetableViewAnalytics {
    func onTimetableViewAppeared()
}

class TimetableViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension TimetableViewViewModel: TimetableViewAnalytics {
    func onTimetableViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "calendar_screen_viewed", metadata: [:]))
    }
}
