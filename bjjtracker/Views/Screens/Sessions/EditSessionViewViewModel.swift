//
//  EditSessionViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

protocol EditSessionViewAnalytics {
    func onScreenAppeared()
    func sessionEdited(_ activity: Activity)
    func sessionDeleted(_ activity: Activity)
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
    
    func sessionEdited(_ activity: Activity) {
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
    
    func sessionDeleted(_ activity: Activity) {
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

extension EditSessionViewViewModel {
    enum Localisation {
        static var selectType: String { "Select type:".localizedString }
        static var selectGrapplingStyle: String { "Select grappling style:".localizedString }
        static var selectDateAndTime: String { "Select date and time:".localizedString }
        static var duration: String { "Duration:".localizedString }
        static var locationTitle: String { "Location:".localizedString }
        static var locationPlaceholder: String { "Location...".localizedString }
        static var notes: String { "Notes".localizedString }
        static var editSession: String { "Edit Session".localizedString }
        static var save: String { "Save".localizedString }
    }
}
