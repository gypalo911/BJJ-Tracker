//
//  bjjtrackerApp.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isTabBarHidden: Bool = false
    @Published var navigateToPage: String?
}

@main
struct bjjtrackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let settings = AppSettings.shared
    let persistanceManager = PersistanceManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(\.managedObjectContext, persistanceManager.container.viewContext)
        }
    }
}
