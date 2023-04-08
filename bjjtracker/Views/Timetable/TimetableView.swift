//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    @State var selectedDay: Date = Date()
    
    @State var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(3000 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Text("Timetable")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding([.leading, .bottom], 20)
                        .hAlign(.leading)
                        .background(Color.white.ignoresSafeArea())
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            MonthCalendarView(activities: $activities, selectedDay: $selectedDay)
                                .background(
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .edgesIgnoringSafeArea(.all)
                                        .cornerRadius(30)
                                        .frame(height: 950)
                                        .position(CGPoint(x: geometry.size.width/2, y: 0))
                                        .defaultShadow()
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
                            
//                            DatePicker("Select Date", selection: $selectedDay, displayedComponents: [.date])
//                                              .padding(.horizontal)
                        }
                    }
                }
                
            }.background(Color("generalBG").ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Image("createButton")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("Blue"))
                        }
                    }
                }
        }
        
    }
}

struct MonthCalendarView: View {
    let days: [String] = Calendar.current.shortWeekdaySymbols
    
    @State var currentMonth: Int = 0
    @State var currentDate: Date = Date()
    
    @Binding var selectedDay: Date
    
    @Binding var activities: [Activity]
    
    init(activities: Binding<[Activity]>, selectedDay: Binding<Date>) {
        _activities = activities
        _selectedDay = selectedDay
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(selectedDay.toString("MMMM YYYY"))")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                Button(action: {
                    print("Calendar tapped")
                }, label: {
                    Image("calendar")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("Blue"))
                })
            }
            
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }.padding(.vertical, 20)
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(extractDate()) { value in
                    CardView(with: value)
                }
            }
        }
        .padding(.all, 20)
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
        
        VStack(spacing: 5) {
            if value.day != -1 {
                ZStack {
                    Circle()
                        .frame(height: 35)
                        .foregroundColor(status ? Color("Blue") : .clear)
                    if isToday {
                        Circle()
                            .stroke(Color("Blue"), lineWidth: 1)
                            .frame(height: 35)
                            .foregroundColor(status ? Color("Blue") : .clear)
                    }
                    Text("\(value.date.toString("d"))")
                        .font(.title3.bold())
                        .foregroundColor(status ? .white : .black)
                }
                Circle()
                    .frame(height: 10)
                    .foregroundColor(activity != nil ? activity!.type.color : .clear)
            }
        }.onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedDay = value.date
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
    
    func extractDate() -> [DateValue] {
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


struct Timetable_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView()
    }
}
