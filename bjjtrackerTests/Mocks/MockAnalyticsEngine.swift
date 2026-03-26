//
//  MockAnalyticsEngine.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 16.06.2023.
//

import Foundation

class MockAnalyticsEngine: AnalyticsEngine {
    private(set) var loggedEvent: AnalyticsEvent?
    
    func log(_ event: AnalyticsEvent) {
        loggedEvent = event
    }
}
