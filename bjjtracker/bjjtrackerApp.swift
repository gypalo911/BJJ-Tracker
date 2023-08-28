//
//  bjjtrackerApp.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct AppConstants {
    static let mgeAnimation = Animation.easeInOut(duration: 0.3)
    
    enum Links: String {
        case patreon = "https://www.patreon.com/gypalo911"
        case buymeacoffee = "https://www.buymeacoffee.com/gypalo911"
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
    
    @Published var healthKitService: HealthKitService = DefaultHealthKitService()
}

@main
struct bjjtrackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let settings = AppSettings.shared
#if DEBUG
    let persistanceManager = PersistanceManager.preview
#else
    let persistanceManager = PersistanceManager.shared
#endif

    var body: some Scene {
        WindowGroup {
#if DEBUG
            ContentView()
                .environmentObject(settings)
                .environmentObject(persistanceManager)
                .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
#else
            ContentView()
                .environmentObject(settings)
                .environmentObject(persistanceManager)
                .environment(\.managedObjectContext, persistanceManager.container.viewContext)
#endif
        }
    }
}
