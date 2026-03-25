//
//  CalendarDayViews.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 07.04.2023.
//

import SwiftUI

struct CalendarDayColors {
    let textColor: Color
    let strokeColor: Color
    let selectedTextColor: Color
    let selectedBGColor: Color
}

struct CalendarDayView: View {
    let date: Date

    let isToday: Bool
    let isSelected: Bool

    let activitiesColors: [Color]
    let colors: CalendarDayColors
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .frame(height: 30)
                    .foregroundColor(isSelected ? colors.selectedBGColor : .clear)
                if isToday {
                    Circle()
                        .stroke(isSelected ? .white : colors.strokeColor, lineWidth: 1)
                        .frame(height: 30)
                        .foregroundColor(isSelected ? colors.selectedBGColor : .clear)
                }
                Text(verbatim: date.toString("d"))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? colors.selectedTextColor : colors.textColor)
                    .frame(maxWidth: .infinity)
            }
            if activitiesColors.isEmpty {
                Circle()
                    .frame(height: 10)
                    .foregroundColor(.clear)
                    .cornerRadius(10)
            } else {
                HStack(spacing: 1) {
                    ForEach(activitiesColors.prefix(3).indices, id: \.self) { index in
                        Circle()
                            .frame(height: 10)
                            .foregroundColor(activitiesColors[index])
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}
