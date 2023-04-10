//
//  DashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

enum ModalsSheets: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case session
    case promotion
}

struct DashboardView: View {
    
    @State private var selectedDay = Date()
    @State private var headerHeight: CGFloat = 550
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    
    private var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(1000 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    private var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    private var currentWeek = Calendar.current.currentWeek
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundColor(Color("Blue"))
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(30)
                        .frame(height: headerHeight)//geometry.size.height/2)
                        .position(CGPoint(x: geometry.size.width/2, y: 0))
                        .defaultShadow()
                    VStack(spacing: 0) {
                        Text("Dashboard")
                            .font(.system(size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            .hAlign(.leading)
                        HStack(spacing: 10) {
                            StatsView(text: "Sessions", value: "3", tendecyGrows: true, tendecyValue: "2")
                            StatsView(text: "Total time", value: "25h", tendecyGrows: false, tendecyValue: "1h 20m")
                        }
                            .padding(.all, 20)
                        
                        WeekCalendarView(
                            selectedDay: $selectedDay,
                            currentWeek: currentWeek,
                            activities: activities,
                            colors: .init(
                                textColor: .white,
                                strokeColor: .white,
                                selectedTextColor: Color("Blue"),
                                selectedBGColor: .white
                            )
                        )
                        if filteredActivities.isEmpty {
                            Spacer()
                            Text("No sessions for this day")
                                .font(.system(size: 18))
                                .foregroundColor(Color("Gray"))
                            Spacer()
                        } else {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(filteredActivities) { activity in
                                        ActivityPanelView(activity: activity)
                                    }
                                }.padding(.bottom, 50)
                            }
                        }
                    }
                }
            }.background(Color("generalBG").ignoresSafeArea())
            .onChange(of: filteredActivities) { items in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.headerHeight = items.isEmpty ? 500 : 550
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingActionSheet = true
                    } label: {
                        Image("createButton")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Action"), buttons: [
                    .default(Text("Add Promotion"), action: {
                        selectedSheet = .promotion
                    }),
                    .default(Text("Add Session"), action: {
                        selectedSheet = .session
                    }),
                    .cancel()
                ])
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView()
                case .session:
                    NewSessionView()
                }
            }
        }.background(Color.white)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
