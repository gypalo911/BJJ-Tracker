//
//  FirebaseAnalyticsEngine.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 16.06.2023.
//

import FirebaseAnalytics

protocol AnalyticsEngine {
    func log(_ event: AnalyticsEvent)
}

struct AnalyticsEvent {
    var name: String
    var metadata: [String: String]
}

enum FirebaseAnalyticsEvent: String {
    case tagAdded = "tag_added"
    case tagRemoved = "tag_removed"
    case journalScreenViewed = "journal_screen_viewed"
    case createSessionButtonTapped = "create_session_button_tapped"
    case addPromotionButtonTapped = "add_promotion_button_tapped"
    case statisticsScreenViewed = "statistics_screen_viewed"
    case openedLinkFromSessionDetails = "opened_link_from_session_details"
    case editSessionScreenViewed = "edit_session_screen_viewed"
    case sessionEdited = "session_edited"
    case sessionDeleted = "session_deleted"
    case dismissedEditSessionScreen = "dismissed_edit_session_screen"
    case newSessionScreenViewed = "new_session_screen_viewed"
    case sessionCreated = "session_created"
    case dismissedNewSessionScreen = "dismissed_new_session_screen"
    case addPromotionScreenViewed = "add_promotion_screen_viewed"
    case promotionCreated = "promotion_created"
    case profileScreenViewed = "profile_screen_viewed"
    case calendarScreenViewed = "calendar_screen_viewed"
    case dashboardScreenViewed = "dashboard_screen_viewed"
}

struct FirebaseAnalyticsEngine: AnalyticsEngine {
    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.metadata)
    }
}
