//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    
    @State private var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120 * 60, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 90 * 60, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90 * 60, startDate: Date() + TimeInterval(3000 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    @State private var selectedDay: Date = Date()
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    
    private var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    
    @State var maxHeight: CGFloat = 400
    
    @State var sliderProgress: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    @State private var showWeekView: Bool = true
    
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
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 10) {
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
                            }.padding(20)
                            Group {
                                if !showWeekView {
                                    MonthCalendarView(selectedDay: $selectedDay, activities: $activities, viewHeight: $sliderHeight, maxHeight: maxHeight)
                                        .frame(height: sliderHeight)
                                        .padding(.top, -30)
                                        .padding(.bottom, -40)
                                } else {
                                    let currentWeek = Calendar.current.week(for: selectedDay)
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
                                    ).padding(.top, -20)
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
                        )
                        .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                            let downDirection = (value.location.y - value.startLocation.y) > 0
                            let translation = value.translation
                            sliderHeight = translation.height + lastDragValue
                            sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                            
                            if sliderHeight <= 310 && !downDirection {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.showWeekView = true
                                }
                            }
                            if sliderHeight > 100 && downDirection {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.showWeekView = false
                                }
                            }
                            sliderHeight = sliderHeight >= 100 ? sliderHeight : 100
                        }).onEnded({ value in
                            sliderHeight = sliderHeight > maxHeight ? maxHeight : sliderHeight
                            
                            sliderHeight = sliderHeight >= 100 ? sliderHeight : 100
                            
                            let downDirection = (value.location.y - value.startLocation.y) > 0
                            
                            if sliderHeight > 100 && downDirection {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.showWeekView = false
                                    self.sliderHeight = maxHeight
                                }
                            }
                            
                            if sliderHeight < maxHeight - 20 && !downDirection {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.showWeekView = true
                                    self.sliderHeight = 200
                                }
                            }
                            
                            lastDragValue = sliderHeight
                        }))
                        ScrollView(showsIndicators: false) {
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
                        }.padding(.top, 20)
                    }
                }
            }.background(Color("generalBG").ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingActionSheet = true
                        } label: {
                            Image("createButton")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("Blue"))
                        }
                    }
                }
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Select Action"), buttons: [
                        .default(Text("Add Promotion"), action: {
                            selectedSheet = .promotion
                        }),
                        .default(Text("Add Session"), action: {
                            selectedSheet = .session
                        }),
                        .cancel()
                    ])
                }
                .sheet(item: $selectedSheet) { selectedSheet in
                    switch selectedSheet {
                    case .promotion:
                        AddPromotionView()
                    case .session:
                        NewSessionView()
                    }
                }
        }
        
    }
}

struct Timetable_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView()
    }
}
