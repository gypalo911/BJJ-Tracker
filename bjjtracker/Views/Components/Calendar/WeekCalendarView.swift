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
    
    var sessions: FetchedResults<Session>

    let colors: CalendarDayColors
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(spacing: 0) {
                ForEach(currentWeek, id: \.self) { day in
                    Text("\(day.dayOfWeek.capitalized)")
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(colors.textColor)
                        .frame(maxWidth: .infinity)
                        .offset(y: 0)
                }
            }
            HStack {
                ForEach(currentWeek, id: \.self.id) { weekDay in
                    
                    let sessionsColors = sessions.filter { session in
                        return Calendar.current.isDate(session.startDate ?? Date(), inSameDayAs: weekDay.date)
                    }.map {
                        $0.activityType.color
                    }
                    
                    let isSelected = Calendar.current.isDate(weekDay.date, inSameDayAs: selectedDay)
                    let isToday = Calendar.current.isDateInToday(weekDay.date)
                    
                    ZStack {
                        CalendarDayView(
                            date: weekDay.date,
                            isToday: isToday,
                            isSelected: isSelected,
                            activitiesColors: sessionsColors,
                            colors: colors
                        )
                    }.onTapGesture {
                        selectDay(weekDay.date)
                    }.onLongPressGesture {
                        selectDay(weekDay.date)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
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
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>

        var body: some View {
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
            .padding(.vertical, 100).background(Rectangle().foregroundColor(.blue))
        }
    }

    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
