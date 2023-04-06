//
//  Dashboard.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct Dashboard: View {
    
    var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(1000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(3000 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    
    @State private var selectedDay = Date()
    @State private var currentWeek = Calendar.current.currentWeek
    
    @State var headerHeight: CGFloat = 550
    
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
                        .foregroundColor(Color(UIColor(named: "Blue") ?? .blue))
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(30)
                        .frame(height: headerHeight)//geometry.size.height/2)
                        .position(CGPoint(x: geometry.size.width/2, y: 0))
                    VStack {
                        StatsView()
                        
                        WeekCalendarView(selectedDay: $selectedDay, currentWeek: $currentWeek, activities: activities)
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
            }.onChange(of: filteredActivities) { items in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.headerHeight = items.isEmpty ? 500 : 550
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Edit button was tapped")
                    } label: {
                        Image("createButton")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }.background(Color.white)
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

struct StatsView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("284")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                Text("Total count of sessions")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("568 hours")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                Text("Total time")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }.padding(.all, 20)
    }
}
