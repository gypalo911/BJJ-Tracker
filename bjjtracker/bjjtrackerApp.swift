//
//  bjjtrackerApp.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct AppConstants {
    static let mgeAnimation = Animation.easeInOut(duration: 0.3)
}

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isTabBarHidden: Bool = false
    @Published var showingActionSheet: Bool = false
    @Published var navigateToPage: String?
    @Published var notificationTime: Int = 3600  // 1 hour
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
