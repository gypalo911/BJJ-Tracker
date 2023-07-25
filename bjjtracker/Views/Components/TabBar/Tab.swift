//
//  Tab.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 22.07.2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case dashboard = "Dashboard"
    case calendar = "Calendar"
    case statistics = "Statistics"
    case profile = "Profile"
    
    var image: Image {
        switch self {
        case .dashboard:
            return Image("dashboard")
        case .profile:
            return Image("profile")
        case .statistics:
            return Image("stats")
        case .calendar:
            return Image("calendar")
        }
    }
    
    var selectedImage: Image {
        switch self {
        case .dashboard:
            return Image("dashboard2")
        case .profile:
            return Image("profile2")
        case .statistics:
            return Image("stats2")
        case .calendar:
            return Image("calendar2")
        }
    }
}
