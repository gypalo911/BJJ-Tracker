//
//  DraggableCalendarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.04.2023.
//

import SwiftUI

struct DraggableCalendarView: View {
    @Binding var activities: [Activity]
    @Binding var selectedDay: Date
    @Binding var isBottomSheetOpen: Bool
    
    private var currentWeek: [Calendar.WeekDay] {
        Calendar.current.week(for: selectedDay)
    }
    
    @State private var maxHeight: CGFloat = 400
    
    @State private var sliderProgress: CGFloat = 0
    @State private var sliderHeight: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    @State private var showWeekView: Bool = true
    @State private var blurCalendar: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(selectedDay.toString("MMMM YYYY"))")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                
                HStack(spacing: 20) {
                    NavigationLink(destination: {
                        StatisticsView(
                            presenter: StatisticsViewPresenter(dateInterval: DateInterval(start: Date() - TimeInterval(5000 * 60), end: Date()))
                        )
                    }) {
                        Image("stats")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    }
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isBottomSheetOpen = true
                        }
                    }, label: {
                        Image("calendar")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    })
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            Group {
                if !showWeekView {
                    MonthCalendarView(
                        selectedDate: $selectedDay,
                        activities: $activities,
                        viewHeight: $sliderHeight,
                        maxHeight: maxHeight
                    )
                    .blur(radius: !blurCalendar ? 5 : 0, opaque: false)
                    .frame(height: sliderHeight)
                    .padding(.top, -60)
                    .padding(.bottom, -40)
                } else {
                    WeekCalendarView(
                        selectedDay: $selectedDay,
                        currentWeek: currentWeek,
                        activities: activities,
                        colors: .init(
                            textColor: .black,
                            strokeColor: .blue,
                            selectedTextColor: .white,
                            selectedBGColor: Color("Blue")
                        )
                    )
                    .blur(radius: blurCalendar ? 5 : 0, opaque: false)
                    .padding(.top, -20)
                }
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("LightGray"))
                .frame(width: 50, height: 6)
                .padding(.bottom, 20)
        }
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
                .frame(maxHeight: .infinity)
                .defaultShadow()
                .mask(Rectangle().fill(.white).padding(.bottom, -20))
        )
        .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
            let downDirection = (value.location.y - value.startLocation.y) > 0
            let translation = value.translation
            sliderHeight = translation.height + lastDragValue
            sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
            
            if sliderHeight <= maxHeight - 20 && !downDirection {
                blurCalendar = false
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showWeekView = true
                }
            }
            if sliderHeight > 100 && downDirection {
                blurCalendar = true
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showWeekView = false
                }
            }
            sliderHeight = sliderHeight >= 100 ? sliderHeight : 100
        }).onEnded({ value in
            sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
            
            sliderHeight = sliderHeight >= 100 ? sliderHeight : 100
            
            let downDirection = (value.location.y - value.startLocation.y) > 0
            
            if sliderHeight > 100 && downDirection {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showWeekView = false
                    self.sliderHeight = maxHeight
                }
            }
            
            if sliderHeight < maxHeight - 20 && !downDirection {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.showWeekView = true
                    self.sliderHeight = 200
                }
            }
            
            lastDragValue = sliderHeight
        }))
    }
}
