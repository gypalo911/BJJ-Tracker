//
//  WeekCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDay: Date
    
    var currentWeek = Calendar.current.currentWeek
    
    init(selectedDay: Binding<Date>, activities: [Activity]) {
        _selectedDay = selectedDay
        activities.forEach { activity in
            currentWeek.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: activity.startDate)
            })?.activityType = activity.type
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            Text("\(Date().toString("MMMM yyyy"))")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            
            HStack {
                ForEach(currentWeek) { weekDay in
                    let status = Calendar.current.isDate(weekDay.date, inSameDayAs: selectedDay)
                    let isToday = Calendar.current.isDateInToday(weekDay.date)
                    ZStack {
//                        Rectangle()
//                            .frame(height: 70)
//                            .foregroundColor(weekDay.activityType != nil ? Color(weekDay.activityType!.color) : .clear)
//                            .cornerRadius(10)
                        VStack(spacing: 5) {
                            Text(weekDay.string.prefix(3))
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(status ? .white : Color(UIColor(named: "LightGray")!))
                                .frame(maxWidth: .infinity)
                            ZStack {
                                Circle()
                                    .frame(height: 30)
                                    .foregroundColor(status ? .white : .clear)
                                if isToday {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(height: 30)
                                        .foregroundColor(status ? .white : .clear)
                                }
                                Text("\(weekDay.date.toString("dd"))")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(status ? .blue : .black)
                                    .frame(maxWidth: .infinity)
                            }
                            Circle()
                                .frame(height: 10)
                                .foregroundColor(weekDay.activityType != nil ? Color(weekDay.activityType!.color) : .clear)
                                .cornerRadius(10)
                        }
                    }.onTapGesture {
                        selectDay(weekDay.date)
                    }.onLongPressGesture {
                        selectDay(weekDay.date)
                    }
                }
            }
        }.padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
    
    private func selectDay(_ day: Date) {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedDay = day
        }
    }
}

struct WeekCalendarView_Previews: PreviewProvider {

    static var previews: some View {
        @State var selectedDay = Date()

        let activities: [Activity] = [
            Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(1000 * 60), location: "Lutsk", notes: "Other notes"),
            Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 500 * 60, location: "Lutsk", notes: "Other notes"),
            Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(3000 * 60), location: "Lutsk", notes: "Other notes"),
        ]
        
        WeekCalendarView(selectedDay: $selectedDay, activities: activities).padding(.vertical, 100).background(Rectangle().foregroundColor(.blue))
    }
}
