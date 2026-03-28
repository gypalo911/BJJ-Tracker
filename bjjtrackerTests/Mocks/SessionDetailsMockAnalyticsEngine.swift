//
//  SessionDetailsMockAnalyticsEngine.swift
//  bjjtrackerTests
//
//  Created by OpenAI on 27.03.2026.
//

import Foundation
@testable import bjjtracker

final class SessionDetailsMockAnalyticsEngine: AnalyticsEngine {
    private(set) var loggedEvent: AnalyticsEvent?

    func log(_ event: AnalyticsEvent) {
        loggedEvent = event
    }
}
