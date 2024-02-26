//
//  NewSessionViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol NewSessionViewAnalytics {
    func onScreenAppeared()
    func sessionCreated(from activity: ActivityModel)
    func popupDismissed()
}

class NewSessionViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension NewSessionViewViewModel: NewSessionViewAnalytics {
    func onScreenAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "new_session_screen_viewed", metadata: [:]))
    }
    
    func sessionCreated(from activity: ActivityModel) {
        analyticsEngine.log(AnalyticsEvent(
            name: "session_created",
            metadata: [
                "id": activity.id.uuidString,
                "type": activity.type.rawValue,
                "style": activity.style.rawValue,
                "startDate": activity.startDate.toString("dd MMMM yyyy"),
                "duration": "\(activity.duration)",
                "status": activity.status.rawValue,
                "location": activity.location,
                "notes": activity.notes
            ]
        ))
    }
    
    func popupDismissed() {
        analyticsEngine.log(AnalyticsEvent(name: "dismissed_new_session_screen", metadata: [:]))
    }
}
