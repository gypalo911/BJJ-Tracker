//
//  CalendarDayViews.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 07.04.2023.
//

import SwiftUI

struct TodayView: View {
    let weekDay: Calendar.WeekDay
    let isToday: Bool
    var activityColor: Color? = .clear
    
    var body: some View {
        VStack(spacing: 5) {
            Text(weekDay.string)
                .font(.callout)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            ZStack {
                Circle()
                    .frame(height: 30)
                    .foregroundColor(.white)
                if isToday {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(height: 30)
                        .foregroundColor(.white)
                }
                Text("\(weekDay.date.toString("dd"))")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
            }
            Circle()
                .frame(height: 10)
                .foregroundColor(activityColor ?? .clear)
                .cornerRadius(10)
        }
    }
}

struct RegularDayView: View {
    let weekDay: Calendar.WeekDay
    let isToday: Bool
    var activityColor: Color? = .clear
    
    var body: some View {
        VStack(spacing: 5) {
            Text(weekDay.string)
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .offset(y: 0)
            ZStack {
                Circle()
                    .frame(height: 30)
                    .foregroundColor(.clear)
                if isToday {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(height: 30)
                        .foregroundColor(.clear)
                }
                Text("\(weekDay.date.toString("dd"))")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            Circle()
                .frame(height: 10)
                .foregroundColor(activityColor ?? .clear)
                .cornerRadius(10)
        }
    }
}
