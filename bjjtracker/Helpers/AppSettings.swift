//
//  AppSettings.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.03.2026.
//

import SwiftUI
import HealthKit

struct AppConstants {
    static let mgeAnimation = Animation.easeInOut(duration: 0.3)
    
    enum Links: String {
        case patreon = "https://www.patreon.com/gypalo911"
        case buymeacoffee = "https://www.buymeacoffee.com/gypalo911"
    }

    enum Config {
        static let supportEmail = Bundle.main.object(forInfoDictionaryKey: "SupportEmail") as? String ?? ""
    }
}

class AppSettings: ObservableObject {
    enum AppLanguage: String {
        case english = "en"
        case ukrainian = "uk"
        
        var stringValue: String {
            switch self {
            case .english:
                return "English"
            case .ukrainian:
                return "Ukrainian"
            }
        }
    }
    
    static let shared = AppSettings()
    
    @Published var isTabBarHidden: Bool = false
    @Published var showingActionSheet: Bool = false
    @Published var showingCreateTechnique: Bool = false
    @Published var selectedSheet: ModalSheets? = nil
//    @Published var selectedBottomSheet: BottomSheets? = nil
    @Published var navigateToPage: String?
    @Published var notificationTime: Int = 3600  // 1 hour
    @Published var appLanguage: AppLanguage = .english
    // Used on Dashboard and Timetable screens when user wants to create a Session or Promotion it automatically uses this variable
    @Published var selectedCalendarDate: Date = Date()
}
