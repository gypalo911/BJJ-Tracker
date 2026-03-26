//
//  ContentView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

@MainActor
struct ContentViewFactory {
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel()
    }

    func makeTimetableViewModel() -> TimetableViewViewModel {
        TimetableViewViewModel()
    }

    func makeStatisticsViewModel() -> StatisticsViewViewModel {
        StatisticsViewViewModel(dateInterval: DateInterval(start: Date(), end: Date()))
    }

    func makeDashboardView(viewModel: DashboardViewModel) -> some View {
        DashboardView(viewModel: viewModel)
    }

    func makeTimetableView(viewModel: TimetableViewViewModel) -> some View {
        TimetableView(viewModel: viewModel)
    }

    func makeStatisticsView(viewModel: StatisticsViewViewModel) -> some View {
        StatisticsView(viewModel: viewModel)
    }

    func makeProfileView(persistanceManager: PersistanceManager) -> some View {
        ProfileView(
            viewModel: ProfileViewViewModel(
                persistanceManager: persistanceManager,
                healthKitService: DefaultHealthKitService(),
                appReview: AppReview()
            )
        )
    }

    func makeBluredBottomSheet(
        isBottomSheetOpen: Binding<Bool>,
        onSelect: @escaping (ModalSheets?) -> Void
    ) -> some View {
        BluredBottomSheet(
            isBottomSheetOpen: isBottomSheetOpen,
            onSelect: onSelect
        )
    }

    func makeTechniqueModalView(showingCreateTechnique: Binding<Bool>) -> some View {
        TechniqueModalView(
            showingCreateTechnique: showingCreateTechnique,
            state: .modifying
        )
    }

    func makeTabBarView(
        selectedTab: Binding<CustomTab>,
        onCreateAction: @escaping () -> Void
    ) -> some View {
        if #available(iOS 26.0, *) {
            return TabBarViewV3(activeTab: selectedTab, onCreateAction: onCreateAction)
        } else {
            return TabBarViewV2(selectedTab: selectedTab, onCreateAction: onCreateAction)
        }
    }

    func makeAddPromotionView() -> some View {
        AddPromotionView(viewModel: .init())
    }

    func makeNewSessionView(persistanceManager: PersistanceManager) -> some View {
        NewSessionView(viewModel: .init(persistanceManager: persistanceManager))
    }
}

@MainActor
struct ContentView: View {
    @State private var selectedTab: CustomTab = .dashboard
    
    @Environment(\.managedObjectContext) var managedObjContext
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    private let factory: ContentViewFactory
    @StateObject private var dashboardVM: DashboardViewModel
    @StateObject private var timetableVM: TimetableViewViewModel
    @StateObject private var statsVM: StatisticsViewViewModel
    
    init() {
        let factory = ContentViewFactory()
        self.factory = factory
        _dashboardVM = StateObject(wrappedValue: factory.makeDashboardViewModel())
        _timetableVM = StateObject(wrappedValue: factory.makeTimetableViewModel())
        _statsVM = StateObject(wrappedValue: factory.makeStatisticsViewModel())
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab.init(value: .dashboard) {
                factory.makeDashboardView(viewModel: dashboardVM)
            }
            Tab.init(value: .calendar) {
                factory.makeTimetableView(viewModel: timetableVM)
            }
            Tab.init(value: .statistics) {
                factory.makeStatisticsView(viewModel: statsVM)
            }
            Tab.init(value: .profile) {
                factory.makeProfileView(persistanceManager: persistanceManager)
            }
        }
        .blurredPopup(isPresented: $settings.showingActionSheet) {
            factory.makeBluredBottomSheet(
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
            factory.makeTechniqueModalView(showingCreateTechnique: $settings.showingCreateTechnique)
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            factory.makeTabBarView(selectedTab: $selectedTab) {
                settings.showingActionSheet = true
            }
            .hideTabBar(settings.isTabBarHidden)
        }
        .sheet(item: $settings.selectedSheet) { selectedSheet in
            switch selectedSheet {
            case .promotion:
                factory.makeAddPromotionView()
            case .activity:
                factory.makeNewSessionView(persistanceManager: persistanceManager)
            }
        }
        .onChange(of: settings.showingActionSheet) { _, value in
            if value {
                settings.isTabBarHidden = true
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    settings.isTabBarHidden = false
                }
            }
        }
        .onChange(of: settings.showingCreateTechnique) { _, value in
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
            let session = persistanceManager.session(by: nav as String)
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
            .environmentObject(PersistanceManager.preview)
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
