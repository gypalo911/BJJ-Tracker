//
//  MonthCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct MonthCalendarView: View {
    private var weekDays: [String] {
        Calendar.current.week(for: selectedDate).map { $0.dayOfWeek }
    }
    
    @State var currentMonthDay: Int = 0
    @State var currentDate: Date = Date()
    
    @Binding var selectedDate: Date
    @Binding var viewHeight: CGFloat
    
    var sessions: FetchedResults<Session>
    
    var maxHeight: CGFloat
    
    let colors: CalendarDayColors = .init(
        textColor: .black,
        strokeColor: .blue,
        selectedTextColor: .white,
        selectedBGColor: Color("DefaultBlue")
    )
    
    var extractedMonthDates: [DateValue] {
        return extractMonthDates()
    }
    
    var body: some View {
        
        VStack {
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day.capitalized)
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(colors.textColor)
                        .frame(maxWidth: .infinity)
                        .offset(y: 0)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(extractedMonthDates) { value in
                    CardView(with: value)
                        .frame(height: (45 * viewHeight) / maxHeight)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onChange(of: currentMonthDay) { newValue in
            selectedDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(with value: DateValue) -> some View {
        let status = Calendar.current.isDate(value.date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(value.date)
        
        let sessionsColors = sessions.filter { session in
            return Calendar.current.isDate(session.startDate ?? Date(), inSameDayAs: value.date)
        }.map {
            $0.activityType.color
        }
        ZStack() {
            if value.day != -1 {
                CalendarDayView(
                    date: value.date,
                    isToday: isToday,
                    isSelected: status,
                    activitiesColors: sessionsColors,
                    colors: colors
                )
                .onTapGesture {
                    selectedDate = value.date
                }
            }
        }
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        guard let currentMonthDay = calendar.date(byAdding: .month, value: currentMonthDay, to: selectedDate) else {
            return Date()
        }
        
        return currentMonthDay
    }
    
    func extractMonthDates() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonthDay = getCurrentMonth()
        
        var days = currentMonthDay.allDatesInMonth().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        var firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
        if firstWeekDay == 1 {
            firstWeekDay += 7
        }
        for _ in 1..<firstWeekDay - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

struct MonthCalendarView_Previews: PreviewProvider {
    struct Container: View {
        @State var selectedDay = Date()
        @State var viewHeight: CGFloat = 400
        
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        
        var maxHeight: CGFloat = 400

        var body: some View {
            MonthCalendarView(
                selectedDate: $selectedDay,
                viewHeight: $viewHeight,
                sessions: sessionsList,
                maxHeight: maxHeight
            )
        }
    }

    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
