//
//  WeekdaysPicker.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.11.2025.
//

import SwiftUI

struct DaysPicker: View {
    enum Day: Int, CaseIterable, Identifiable {
        case Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7, Sunday = 1

        var id: Int { rawValue }
        
        var title: String {
            localizedTitle.prefix(3).uppercased()
        }
        
        var localizedTitle: String {
            let calendar = Calendar.current
            let now = Date()
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekday = self.rawValue
            let dateForWeekday = calendar.date(from: components) ?? now

            return dateForWeekday.formatted(.dateTime.weekday(.wide))
        }
    }

    @Binding var selectedDays: [Day]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Day.allCases, id: \.self) { day in
                    Text(String(day.title))
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .frame(width: 45, height: 45)
                        .background(Circle().fill(
                            selectedDays.contains(day) ? Color("Blue") : Color("LightGray")
                        ))
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                if selectedDays.count > 1 {
                                    selectedDays.removeAll(where: {$0 == day})
                                }
                            } else {
                                selectedDays.append(day)
                                print(day.localizedTitle)
                            }
                        }
                }
            }
        }
    }
}

struct Demo: View {
    @State var selectedDays: [DaysPicker.Day] = [.Monday]
    
    var body: some View {
        DaysPicker(selectedDays: $selectedDays)
    }
}

#Preview {
    Demo()
}
