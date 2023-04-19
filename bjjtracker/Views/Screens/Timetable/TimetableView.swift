//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    
    @State private var activities: [Activity] = [
        Activity(type: .seminar, style: .noGi, duration: 120, startDate: Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 26))!, location: "Lutsk", notes: "26 of March\nSome notes"),
        Activity(type: .seminar, style: .noGi, duration: 120, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .session, style: .gi, duration: 120, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
        Activity(type: .competition, style: .noGi, duration: 90, startDate: Date() + TimeInterval(3000 * 60), location: "Lutsk", notes: "Some notes"),
        Activity(type: .seminar, style: .noGi, duration: 90, startDate: Date() + TimeInterval(3010 * 60), location: "Lutsk", notes: "Some notes"),
    ]
    
    @State private var selectedDay: Date = Date()
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    
    @State private var selectedActivity: Activity?
    
    @State private var newActivity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "asdsad", notes: "asdasdas")
    
    private var filteredActivities: [Activity] {
        activities.filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDay)
        }
    }
    
    private var currentWeek: [Calendar.WeekDay] {
        Calendar.current.week(for: selectedDay)
    }
    
    @State var maxHeight: CGFloat = 400
    
    @State var sliderProgress: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var lastDragValue: CGFloat = 0
    
    @State private var showWeekView: Bool = true
    @State private var blurCalendar: Bool = false
    
    @State private var isBottomSheetOpen: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Timetable")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding([.leading, .bottom], 20)
                    .hAlign(.leading)
                    .background(Color.white.ignoresSafeArea())
                
                VStack(spacing: 0) {
                    DraggableCalendarView(
                        activities: $activities,
                        selectedDay: $selectedDay,
                        isBottomSheetOpen: $isBottomSheetOpen
                    )
                    if filteredActivities.isEmpty {
                        Spacer()
                        Text("No sessions for this day")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Gray"))
                        NavigationLink(destination: {
                            ArchiveView(activities: activities)
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                        }) {
                            HStack {
                                Text("View History")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                Image("archive")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.top, 20)
                        Spacer()
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(filteredActivities) { activity in
                                    ActivityPanelView(activity: activity)
                                        .onTapGesture {
                                            selectedActivity = activity
                                        }
                                }
                                NavigationLink(destination: {
                                    ArchiveView(activities: activities)
                                        .navigationBarTitle("")
                                        .navigationBarHidden(true)
                                }) {
                                    HStack {
                                        Text("View History")
                                            .font(.system(size: 16))
                                            .foregroundColor(.blue)
                                        Image("archive")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .padding(.top, 20)
                            }
                            .padding(.bottom, 50)
                            .padding(.top, 20)
                        }
                    }
                }.padding(.top, -10)
            }
            .background(Color("generalBG").ignoresSafeArea())
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
                    NewSessionView(activity: $newActivity, isEditing: false)
                }
            }
            .fullScreenCover(isPresented: $isBottomSheetOpen) {
                MonthYearBottomSheetView(
                    selectedDate: $selectedDay,
                    isBottomSheetOpen: $isBottomSheetOpen
                )
            }
            .sheet(item: $selectedActivity) { selectedActivity in
                SessionDetailsView(activity: selectedActivity)
            }
        }
    }
}

struct Timetable_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView()
    }
}
