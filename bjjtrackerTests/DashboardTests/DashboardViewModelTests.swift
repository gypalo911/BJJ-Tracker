//
//  DashboardViewModelTests.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 16.06.2023.
//

import XCTest
@testable import bjjtracker

final class DashboardViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func test_onDashboardAppear_whenViewAppears_willLogEvent() throws {
        let analyticsEngine = MockAnalyticsEngine()
        let vm = DashboardViewModel(analyticsEngine: analyticsEngine)

        XCTAssertNil(analyticsEngine.loggedEvent)

        vm.onDashboardAppear()
        
        XCTAssertEqual(analyticsEngine.loggedEvent?.name, "dashboard_screen_viewed")
    }
    
    @MainActor
    func test_selectedModal_whenActivitySelected_willLogEvent() throws {
        let analyticsEngine = MockAnalyticsEngine()
        let vm = DashboardViewModel(analyticsEngine: analyticsEngine)

        XCTAssertNil(analyticsEngine.loggedEvent)

        vm.selectedModal("activity")

        XCTAssertEqual(analyticsEngine.loggedEvent?.name, "activity_from_dashboard_selected")
    }
    
    @MainActor
    func test_selectedModal_whenPromotionSelected_willLogEvent() throws {
        let analyticsEngine = MockAnalyticsEngine()
        let vm = DashboardViewModel(analyticsEngine: analyticsEngine)

        XCTAssertNil(analyticsEngine.loggedEvent)

        vm.selectedModal("promotion")

        XCTAssertEqual(analyticsEngine.loggedEvent?.name, "promotion_from_dashboard_selected")
    }
}
