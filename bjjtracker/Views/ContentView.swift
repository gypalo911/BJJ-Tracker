//
//  ContentView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tag(Tab.dashboard)
                    TimetableView()
                        .tag(Tab.calendar)
                    StatisticsView(
                        presenter: StatisticsViewPresenter(dateInterval: DateInterval(start: Date(), end: Date()))
                    ).tag(Tab.statistics)
                    ProfileView()
                        .tag(Tab.profile)
                }.edgesIgnoringSafeArea(.bottom)
            }
            VStack {
                Spacer()
                if !settings.isTabBarHidden {
                    CustomTabBarView(selectedTab: $selectedTab)
                }
            }
        }.ignoresSafeArea()
    }
}

class AppSettings: ObservableObject {
    @Published var isTabBarHidden: Bool = false
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let settings: AppSettings = AppSettings()
        ContentView()
            .environmentObject(settings)
    }
}
