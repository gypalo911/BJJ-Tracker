//
//  ContentView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
    @Environment (\.managedObjectContext) var managedObjContext
    @StateObject var dashboardVM = DashboardViewModel()
    @StateObject var profileVM = ProfileViewViewModel()
    @StateObject var timetableVM = TimetableViewViewModel()
    @StateObject var statsVM = StatisticsViewViewModel(dateInterval: DateInterval(start: Date(), end: Date()))
    
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    DashboardView(viewModel: dashboardVM)
                        .tag(Tab.dashboard)
                    TimetableView(viewModel: timetableVM)
                        .tag(Tab.calendar)
                    StatisticsView(viewModel: statsVM)
                        .tag(Tab.statistics)
                    ProfileView(viewModel: profileVM)
                        .tag(Tab.profile)
                }
            }
            if !settings.isTabBarHidden {
                CustomTabBarView(selectedTab: $selectedTab)
                    .vAlign(.bottom)
                    .disabled(settings.isTabBarHidden)
            }
        }
        .ignoresSafeArea()
        .onReceive(AppSettings.shared.$navigateToPage) { nav in
            guard let nav = nav else {
                return
            }
            let session = PersistanceManager.shared.session(by: nav as String, context: managedObjContext)
            guard let session = session else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                dashboardVM.selectedSession = session
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
