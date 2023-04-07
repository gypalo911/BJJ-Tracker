//
//  ContentView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tag(Tab.dashboard)
                    TimetableView()
                        .tag(Tab.calendar)
                    Text("Profile")
                        .tag(Tab.profile)
                }
            }
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: $selectedTab)
            }
        }.ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
