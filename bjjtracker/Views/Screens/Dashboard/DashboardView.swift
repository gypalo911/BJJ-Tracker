//
//  DashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct DashboardView: View {
    
    @FetchRequest var sessionsList: FetchedResults<Session>
    
    @ObservedObject private var viewModel: DashboardViewModel
    
    @State private var headerHeight: CGFloat = 660
    
    private var filteredSessions: [Session] {
        sessionsList.filter {
            viewModel.isDateSelected($0.startDate ?? Date())
        }
    }
    
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
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundColor(Color("Blue"))
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(30)
                        .frame(height: headerHeight)
                        .position(CGPoint(x: geometry.size.width/2, y: 0))
                        .defaultShadow()
                    VStack(spacing: 0) {
                        HStack {
                            Text("Dashboard")
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .hAlign(.leading)
                            
                            Button {
                                viewModel.showingActionSheet = true
                            } label: {
                                Image("createButton")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .hAlign(.trailing)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                        
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
                        
                        HStack {
                            Text("\(viewModel.selectedDay.toString("LLLL yyyy").capitalized)")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .hAlign(.leading)
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
                                selectedTextColor: Color("Blue"),
                                selectedBGColor: .white
                            )
                        )
                        if filteredSessions.isEmpty {
                            Spacer()
                            Text("No sessions for this day")
                                .font(.system(size: 18))
                                .foregroundColor(Color("Gray"))
                            
                            NavigationLink(destination: {
                                ArchiveView()
                                    .navigationBarTitle("")
                                    .navigationBarHidden(true)
                            }) {
                                HStack {
                                    Text("View History")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                    Image("archive")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding(.top, 20)
                            Spacer()
                        } else {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(filteredSessions) { session in
                                        if session.id != nil {
                                            ActivityPanelView(session: session)
                                                .onTapGesture {
                                                    viewModel.select(session: session)
                                                }
                                        }
                                    }
                                    
                                    NavigationLink(destination: {
                                        ArchiveView()
                                            .navigationBarTitle("")
                                            .navigationBarHidden(true)
                                    }) {
                                        HStack {
                                            Text("View History")
                                                .font(.system(size: 16))
                                                .foregroundColor(.blue)
                                            Image("archive")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.top, 20)
                                }.padding(.bottom, 50)
                            }
                        }
                    }
                }
            }
            .background(Color("generalBG").ignoresSafeArea())
            .onChange(of: filteredSessions) { items in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.headerHeight = items.isEmpty ? 620 : 660
                }
            }
            .actionSheet(isPresented: $viewModel.showingActionSheet) {
                ActionSheet(title: Text("Select Action"), buttons: [
                    .default(Text("Add Promotion"), action: {
                        viewModel.selectModal(sheet: .promotion)
                    }),
                    .default(Text("Add Session"), action: {
                        viewModel.selectModal(sheet: .activity)
                    }),
                    .cancel()
                ])
            }
            .sheet(item: $viewModel.selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView()
                case .activity:
                    NewSessionView()
                }
            }
            .sheet(item: $viewModel.selectedSession) { selectedSession in
                SessionDetailsView(session: selectedSession)
            }
            .onAppear {
                NotificationManager.shared.requestAuthorization { _ in }
                viewModel.onDashboardAppear()
            }
        }.background(Color.white)
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
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
