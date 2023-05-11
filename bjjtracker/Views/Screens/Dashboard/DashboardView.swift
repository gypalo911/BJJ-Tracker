//
//  DashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

enum ModalsSheets: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case activity
    case promotion
}

struct DashboardView: View {
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
    
    @State var selectedSession: Session?
    
    @State private var selectedDay = Date()
    @State private var headerHeight: CGFloat = 660
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    
    private var filteredSessions: [Session] {
        sessionsList.filter {
            Calendar.current.isDate($0.startDate ?? Date(), inSameDayAs: selectedDay)
        }
    }
    private var currentWeekSessions: [Session] {
        let start = currentWeek.first?.date ?? Date()
        let end = currentWeek.last?.date ?? Date()
        return sessionsList.filter {
            (start...end).contains($0.startDate ?? Date())
        }
    }
    private var lastWeekSessions: [Session] {
        let lastWeekDate = Calendar.current.week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!)
        let start = lastWeekDate.first?.date ?? Date()
        let end = lastWeekDate.last?.date ?? Date()
        return sessionsList.filter {
            (start...end).contains($0.startDate ?? Date())
        }
    }
    private var currentWeek = Calendar.current.currentWeek
    
    func totalTime(_ sessions: [Session]) -> Int {
        return sessions.map { Int($0.duration) }.reduce(0, +)
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
                                showingActionSheet = true
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
                            StatsView(text: "Sessions", value: "\(currentWeekSessions.count)", tendecyGrows: currentWeekSessions.count > lastWeekSessions.count, tendecyValue: "\(abs(currentWeekSessions.count - lastWeekSessions.count))")
                            StatsView(
                                text: "Total time",
                                value: totalTime(currentWeekSessions).minutesToDuration(), tendecyGrows: totalTime(currentWeekSessions) > totalTime(lastWeekSessions),
                                tendecyValue: "\(abs(totalTime(currentWeekSessions) - totalTime(lastWeekSessions)).minutesToDuration())"
                            )
                        }
                        .padding(.all, 20)
                        
                        HStack {
                            Text("\(selectedDay.toString("MMMM yyyy"))")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .hAlign(.leading)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        
                        WeekCalendarView(
                            selectedDay: $selectedDay,
                            currentWeek: currentWeek,
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
                                                    self.selectedSession = session
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
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Action"), buttons: [
                    .default(Text("Add Promotion"), action: {
                        selectedSheet = .promotion
                    }),
                    .default(Text("Add Session"), action: {
                        selectedSheet = .activity
                    }),
                    .cancel()
                ])
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView()
                case .activity:
                    NewSessionView()
                }
            }
            .sheet(item: $selectedSession) { selectedSession in
                SessionDetailsView(session: selectedSession)
            }
        }.background(Color.white)
    }
}

struct Dashboard_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            DashboardView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}
