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

struct FirebaseAnalyticsEngine: AnalyticsEngine {
    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.metadata)
    }
}
