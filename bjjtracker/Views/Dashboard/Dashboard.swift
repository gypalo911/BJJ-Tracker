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
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Rectangle()
                        .foregroundColor(Color(UIColor(named: "Blue") ?? .blue))
                        .edgesIgnoringSafeArea(.all)
                        .cornerRadius(30)
                        .frame(height: 550)//geometry.size.height/2)
                        .position(CGPoint(x: geometry.size.width/2, y: 0))
                    VStack {
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
                        
                        WeekCalendarView(selectedDay: $selectedDay, activities: activities)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(filteredActivities) { activity in
                                    ActivityPanelView(activity: activity)
                                }
                            }
                        }
                    }
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
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

struct SelectedDayWithActivity: View {
    let weekday: String
    let day: Int
    let selectedDay: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 70)
                .foregroundColor(Color(UIColor(named: "Seminar")!))
                .cornerRadius(10)
            VStack(spacing: 15) {
                Text(weekday)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor(named: "LightGray")!))
                    .frame(maxWidth: .infinity)
                if day == selectedDay {
                    ZStack {
                        Circle()
                            .frame(height: 30)
                            .foregroundColor(.white)
                        Text("\(day)")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    Text("\(day)")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
