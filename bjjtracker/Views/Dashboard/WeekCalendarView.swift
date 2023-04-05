//
//  WeekCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct WeekCalendarView: View {
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let numbers = [1,2,3,4,5,6,7]
    
    @State var selectedDay = 4
    let seminarDay = 6
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("April 2023")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            
            HStack {
                ForEach(Array(zip(days, numbers)), id: \.0) { item in
                    ZStack {
                        Rectangle()
                            .frame(height: 70)
                            .foregroundColor(item.1 == seminarDay ? Color(UIColor(named: "Seminar")!) : .clear)
                            .cornerRadius(10)
                        VStack(spacing: 5) {
                            Text(item.0)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(item.1 == selectedDay ? .white : Color(UIColor(named: "LightGray")!))
                                .frame(maxWidth: .infinity)
                            ZStack {
                                Circle()
                                    .frame(height: 30)
                                    .foregroundColor(item.1 == selectedDay ? .white : .clear)
                                Text("\(item.1)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(item.1 == selectedDay ? .blue : .black)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }.onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.25)) {
                            selectedDay = item.1
                        }
                    }
                }
            }
        }.padding(.horizontal, 20)
    }
}

struct WeekCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        WeekCalendarView()
    }
}
