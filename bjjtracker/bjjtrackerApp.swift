//
//  bjjtrackerApp.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

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

