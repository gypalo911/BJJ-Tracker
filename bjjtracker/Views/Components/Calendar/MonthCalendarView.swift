//
//  MonthCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct MonthCalendarView: View {
    let days: [String] = Calendar.current.shortWeekdaySymbols
    
    @State var currentMonth: Int = 0
    @State var currentDate: Date = Date()
    
    @Binding var selectedDay: Date
    @Binding var activities: [Activity]
    @Binding var viewHeight: CGFloat
    
    var maxHeight: CGFloat
    
    let colors: CalendarDayColors = .init(
        textColor: .black,
        strokeColor: .blue,
        selectedTextColor: .white,
        selectedBGColor: Color("Blue")
    )
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(colors.textColor)
                        .frame(maxWidth: .infinity)
                        .offset(y: 0)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(extractMonthDates) { value in
                    CardView(with: value)
                        .frame(height: (45 * viewHeight) / maxHeight)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onChange(of: currentMonth) { newValue in
            selectedDay = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(with value: DateValue) -> some View {
        let status = Calendar.current.isDate(value.date, inSameDayAs: selectedDay)
        let isToday = Calendar.current.isDateInToday(value.date)
        
        let activity = activities.first(where: { activity in
            return Calendar.current.isDate(activity.startDate, inSameDayAs: value.date)
        })
        VStack(spacing: 0) {
            if value.day != -1 {
                CalendarDayView(
                    date: value.date,
                    isToday: isToday,
                    isSelected: status,
                    activityColor: activity?.type.color,
                    colors: colors
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedDay = value.date
                    }
                }
            }
        }
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: currentMonth, to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
    var extractMonthDates: [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.allDatesInMonth().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
        for _ in 0..<firstWeekDay - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

struct MonthCalendarView_Previews: PreviewProvider {
    struct Container: View {
        @State var selectedDay = Date()
        @State var viewHeight: CGFloat = 400
        
        @State var activities: [Activity] = [
            Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Other notes"),
            Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 500 * 60, location: "Lutsk", notes: "Other notes"),
            Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(1000 * 60), location: "Lutsk", notes: "Other notes"),
        ]
        
        var maxHeight: CGFloat = 400
        
        var body: some View {
            MonthCalendarView(
                selectedDay: $selectedDay,
                activities: $activities,
                viewHeight: $viewHeight,
                maxHeight: maxHeight
            )
        }
    }
    
    static var previews: some View {
        Container()
    }
}
