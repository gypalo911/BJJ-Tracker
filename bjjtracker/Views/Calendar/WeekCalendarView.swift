//
//  WeekCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDay: Date
    var currentWeek: [Calendar.WeekDay]
    
    let activities: [Activity]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            Text("\(Date().toString("MMMM yyyy"))")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            
            HStack {
                ForEach(currentWeek, id: \.self.id) { weekDay in
                    
                    let activity = activities.first(where: { activity in
                        return Calendar.current.isDate(activity.startDate, inSameDayAs: weekDay.date)
                    })
                    
                    let isSelected = Calendar.current.isDate(weekDay.date, inSameDayAs: selectedDay)
                    let isToday = Calendar.current.isDateInToday(weekDay.date)
                    
                    ZStack {
                        if isSelected {
                            TodayView(weekDay: weekDay, isToday: isToday, activityColor: activity?.type.color)
                        } else {
                            RegularDayView(weekDay: weekDay, isToday: isToday, activityColor: activity?.type.color)
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
    struct Container: View {
        @State var selectedDay = Date()
        var currentWeek = Calendar.current.currentWeek
        
        let activities: [Activity] = [
            Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Other notes"),
            Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 500 * 60, location: "Lutsk", notes: "Other notes"),
            Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(1000 * 60), location: "Lutsk", notes: "Other notes"),
        ]
        
        var body: some View {
            WeekCalendarView(selectedDay: $selectedDay, currentWeek: currentWeek, activities: activities).padding(.vertical, 100).background(Rectangle().foregroundColor(.blue))
        }
    }
    
    static var previews: some View {
        Container()
    }
}
