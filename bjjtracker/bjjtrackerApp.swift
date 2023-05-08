//
//  bjjtrackerApp.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

@main
struct bjjtrackerApp: App {
    
    let settings = AppSettings()
    let persistanceManager = PersistanceManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(\.managedObjectContext, persistanceManager.container.viewContext)
        }
    }
}
