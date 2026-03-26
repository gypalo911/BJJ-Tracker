//
//  DashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct DashboardView: View {
    enum Localisation {
        static let dashboard = "Dashboard"
        static let viewHistory = "View History"
        static let emptyDay = "No sessions for this day"
        static let caloriesBurned = "%@ calories burned"
    }
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @FetchRequest var sessionsList: FetchedResults<Session>
    
    @ObservedObject private var viewModel: DashboardViewModel
    
    @State private var headerHeight: CGFloat = 680
    @State private var offsetY: CGFloat = .zero
    @State private var shouldCollapseHeader: Bool = false
    @State private var isConnectAHPresented: Bool = false
    
    @Namespace var namespace
    
    private var filteredSessions: [Session] {
        sessionsList.filter {
            viewModel.isDateSelected($0.startDate ?? Date())
        }
    }
    
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        _sessionsList = FetchRequest<Session>(
            sortDescriptors: [],
            predicate: NSPredicate(
                format: "startDate >= %@ AND startDate <= %@",
                viewModel.requestDateRange.start as CVarArg,
                viewModel.requestDateRange.end as CVarArg
            )
        )
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .foregroundColor(DesignSystem.shared.colors.blue)
                            .edgesIgnoringSafeArea(.all)
                            .cornerRadius(30)
                            .frame(height: shouldCollapseHeader ? headerHeight / 2 + 80 : headerHeight)
                            .position(CGPoint(x: screenSize.width / 2, y: 0))
                            .offset(y: shouldCollapseHeader ? -offsetY : 0)
                            .defaultShadow()
                        VStack(spacing: 0) {
                            HStack {
                                Text(Localisation.dashboard.localizedString)
                                    .font(token: DesignSystem.shared.fonts.title, weight: .bold)
                                    .foregroundColor(.white)
                                    .hAlign(.leading)
                                
                                Button {
                                    settings.showingActionSheet = true
                                } label: {
                                    Image("createButton")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                }
                                .hAlign(.trailing)
                            }
                            .offset(y: -offsetY)
                            .padding(.horizontal, 20)
                            .padding([.bottom, .top], 10)
                            .zIndex(3)
                            if !shouldCollapseHeader {
                                HeaderView()
                                    .zIndex(3)
                            }
                            CalendarHeaderView()
                                .offset(y: shouldCollapseHeader ? -offsetY : 0)
                                .background(
                                    Rectangle()
                                        .foregroundColor(DesignSystem.shared.colors.blue)
                                        .edgesIgnoringSafeArea(.all)
                                        .cornerRadius(30)
                                        .frame(height: headerHeight/2)
                                        .position(CGPoint(x: screenSize.width / 2, y: -50))
                                        .offset(y: -offsetY)
                                        .opacity(shouldCollapseHeader ? 1 : 0)
                                )
                                .zIndex(2)
                            
                            Group {
                                if filteredSessions.isEmpty {
                                    EmptyResultsView()
                                } else {
                                    ResultsView()
                                }
                            }
                            .zIndex(0)
                        }
                    }
                    .offset(coordinateSpace: .named("scroll")) { offset in
                        offsetY = offset
                        withAnimation(.easeInOut(duration: 0.5)) {
                            if offset <= -50 {
                                shouldCollapseHeader = true
                            }
                            if offset >= 50 {
                                shouldCollapseHeader = false
                            }
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .backport.hiddenToolbar(true)
                .background(DesignSystem.shared.colors.generalBackground.ignoresSafeArea())
                .onChange(of: viewModel.selectedDay) { _, value in
                    settings.selectedCalendarDate = value.setCurrentTime()
                    viewModel.setupHealthData()
                }
                .onChange(of: filteredSessions) { items, _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.headerHeight = items.isEmpty ? 620 : 680
                    }
                }
                .onAppear {
                    settings.isTabBarHidden = false
                    viewModel.onDashboardAppeared()
                }
            }
            .onChange(of: isConnectAHPresented) { _, value in
                settings.isTabBarHidden = value
            }
            .bottomSheet(isPresented: $isConnectAHPresented, view: {
                ConnectAppleHealthView(onConnect: {
                    viewModel.authorizeHealthKitIfNeeded {
                        isConnectAHPresented = false
                    }
                })
            })
            .zIndex(0)
            
            if let session = viewModel.selectedSession {
                SessionDetailsView(
                    namespace: namespace,
                    viewModel: SessionDetailsViewModel(
                        session: session,
                        persistanceManager: persistanceManager
                    ), dismissCallback: {
                        DispatchQueue.main.async {
                            withAnimation(AppConstants.mgeAnimation) {
                                viewModel.selectedSession = nil
                                settings.isTabBarHidden = false
                            }
                        }
                    }
                ).zIndex(1)
            }
        }
        .task {
//            let totalEnergy = await settings.healthKitService.energyStatisticsValue(
//                dateInterval: DateInterval(start: Date().startOfDay, end: Date().endOfDay),
//                calculation: .sum
//            )
//            print("totalEnergy \(totalEnergy)")
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack(spacing: 10) {
            let (week1, week2) = viewModel.lastTwoWeeksSessions(sessionsList.map { $0 })
            StatsView(
                text: "Sessions".localizedString,
                value: "\(week1.count)",
                tendecyGrows: week1.count > week2.count,
                tendecyValue: "\(abs(week1.count - week2.count))"
            )
            StatsView(
                text: "Total time".localizedString,
                value: viewModel.totalTime(week1).minutesToDuration(),
                tendecyGrows: viewModel.totalTime(week1) > viewModel.totalTime(week2),
                tendecyValue: "\(abs(viewModel.totalTime(week1) - viewModel.totalTime(week2)).minutesToDuration())"
            )
        }
        .padding(.all, 20)
    }
    
    @ViewBuilder
    func CalendarHeaderView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(verbatim: viewModel.selectedDay.toString("LLLL yyyy").capitalized)
                    .font(token: DesignSystem.shared.fonts.title2, weight: .bold)
                    .foregroundColor(.white)
                    .hAlign(.leading)
                
                
                NavigationLink(destination: {
                    JournalView(viewModel: .init(persistanceManager: persistanceManager))
                }) {
                    Image("archive")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            WeekCalendarView(
                selectedDay: $viewModel.selectedDay,
                currentWeek: viewModel.currentWeek,
                sessions: sessionsList,
                colors: .init(
                    textColor: .white,
                    strokeColor: .white,
                    selectedTextColor: DesignSystem.shared.colors.blue,
                    selectedBGColor: .white
                )
            )
        }
    }
    
    @ViewBuilder
    func ResultsView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if !viewModel.isHealthKitAuthorized {
                    AppleHealthCardView {
                        isConnectAHPresented = true
                        settings.isTabBarHidden = true
                    }
                } else {
                    let totalEnergyBurned = Int(viewModel.healthData.totalEnergyBurned)
//                    let workoutsCount = Int(viewModel.healthData.workoutsCount)
                    if totalEnergyBurned != 0 {
                        CommonCardView(
                            image: {
                                Image(systemName: "flame.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.red)
                            }, text: {
                                Text(Localisation.caloriesBurned.localized(with: ["\(totalEnergyBurned)"]))
                                    .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                                    .foregroundColor(.black)
                            }
                        )
                    }
//                    if workoutsCount != 0 {
//                        CommonCardView(
//                            image: {
//                                Image("activities")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 25, height: 25)
//                                    .foregroundColor(.black)
//                            },
//                            text: {
//                                Text("**\(workoutsCount)** activities beside BJJ")
//                                    .font(token: DesignSystem.shared.fonts.footnote)
//                                    .foregroundColor(.black)
//                            }
//                        )
//                    }
                }
                
                ForEach(filteredSessions) { session in
                    let sessionId = session.id?.uuidString ?? ""
                    if viewModel.selectedSession == nil {
                        ActivityPanelView(session: session)
                            .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace)
                            .onTapGesture {
                                withAnimation(AppConstants.mgeAnimation) {
                                    viewModel.select(session: session)
                                }
                            }
                    } else {
                        ActivityPanelView(session: session)
                    }
                }
                
                NavigationLink(destination: {
                    JournalView(viewModel: .init(persistanceManager: persistanceManager))
                }) {
                    HStack {
                        Text(Localisation.viewHistory.localizedString)
                            .font(.callout)
                            .foregroundColor(.blue)
                        Image("archive")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.top, 20)
            }.padding(.bottom, settings.isTabBarHidden ? 50 : 120)
        }
    }
    
    @ViewBuilder
    func EmptyResultsView() -> some View {
        Spacer()
        Text(Localisation.emptyDay.localizedString)
            .font(token: DesignSystem.shared.fonts.body)
            .foregroundColor(DesignSystem.shared.colors.gray)
        
        NavigationLink(destination: {
            JournalView(viewModel: .init(persistanceManager: persistanceManager))
        }) {
            HStack {
                Text(Localisation.viewHistory.localizedString)
                    .font(.callout)
                    .foregroundColor(.blue)
                Image("archive")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.top, 20)
        Spacer()
    }
}

struct Dashboard_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            DashboardView(
                viewModel: DashboardViewModel(
                    analyticsEngine: FirebaseAnalyticsEngine()
                )
            )
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
