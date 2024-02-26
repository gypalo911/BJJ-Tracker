//
//  EditSessionViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol EditSessionViewAnalytics {
    func onScreenAppeared()
    func sessionEdited(_ activity: ActivityModel)
    func sessionDeleted(_ activity: ActivityModel)
    func popupDismissed()
}

class EditSessionViewViewModel: ObservableObject {
    
    private let analyticsEngine: AnalyticsEngine
    
    init(analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.analyticsEngine = analyticsEngine
    }
}

extension EditSessionViewViewModel: EditSessionViewAnalytics {
    func onScreenAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "edit_session_screen_viewed", metadata: [:]))
    }
    
    func sessionEdited(_ activity: ActivityModel) {
        analyticsEngine.log(AnalyticsEvent(
            name: "session_edited",
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
    
    func sessionDeleted(_ activity: ActivityModel) {
        analyticsEngine.log(AnalyticsEvent(
            name: "session_deleted",
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
        analyticsEngine.log(AnalyticsEvent(name: "dismissed_edit_session_screen", metadata: [:]))
    }
}
