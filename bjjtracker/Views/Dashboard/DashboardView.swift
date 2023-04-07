//
//  DashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct DashboardView: View {
    
    var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(1000 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    
    @State private var selectedDay = Date()
    var currentWeek = Calendar.current.currentWeek
    
    @State var headerHeight: CGFloat = 650
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "Blue")
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
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
                            StatsView(text: "Total time", value: "2568h", tendecyGrows: false, tendecyValue: "1h 20m")
                        }
                            .padding(.all, 20)
                        
                        WeekCalendarView(selectedDay: $selectedDay, currentWeek: currentWeek, activities: activities)
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
                    self.headerHeight = items.isEmpty ? 600 : 650
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Edit button was tapped")
                    } label: {
                        Image("createButton")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
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
