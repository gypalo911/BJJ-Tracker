//
//  ContentView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI
import Introspect

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    
    @Environment (\.managedObjectContext) var managedObjContext
    @StateObject var dashboardVM = DashboardViewModel()
    @StateObject var profileVM = ProfileViewViewModel()
    @StateObject var timetableVM = TimetableViewViewModel()
    @StateObject var statsVM = StatisticsViewViewModel(dateInterval: DateInterval(start: Date(), end: Date()))
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager

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
            .blurredPopup(isPresented: $settings.showingActionSheet) {
                BluredBottomSheet(
                    isBottomSheetOpen: $settings.showingActionSheet,
                    onSelect: { modal in
                        if let modal = modal {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                settings.selectedSheet = modal
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                settings.showingCreateTechnique = true
                            }
                        }
                    }
                )
            }
            .bottomSheet(isPresented: $settings.showingCreateTechnique) {
                TechniqueModalView(state: .modifying)
            }
            if !settings.isTabBarHidden {
                FloatingTabBarView(selectedTab: $selectedTab, onCreate: {
                    settings.showingActionSheet = true
                })
                .vAlign(.bottom)
                .padding(.bottom, 30)
                .disabled(settings.isTabBarHidden)
            }
        }
        .ignoresSafeArea()
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
        .sheet(item: $settings.selectedSheet) { selectedSheet in
            switch selectedSheet {
            case .promotion:
                AddPromotionView(viewModel: .init())
            case .activity:
                NewSessionView(viewModel: .init())
            }
        }
        .onChange(of: settings.showingActionSheet) { value in
            if value {
                settings.isTabBarHidden = true
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    settings.isTabBarHidden = false
                }
            }
        }
        .onChange(of: settings.showingCreateTechnique) { value in
            if value {
                settings.isTabBarHidden = true
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    settings.isTabBarHidden = false
                }
            }
        }
        .onReceive(AppSettings.shared.$navigateToPage) { nav in
            guard let nav = nav else {
                return
            }
            let session = persistanceManager.session(by: nav as String, context: managedObjContext)
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
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
        
        ContentView()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iphone 7 ios 15"))
            .previewDisplayName("iphone 7 ios 15")
    }
}
