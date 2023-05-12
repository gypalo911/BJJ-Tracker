//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
    
    @State private var selectedDay: Date = Date()
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    
    @State var selectedSession: Session?
    
    private var filteredSessions: [Session] {
        sessionsList.filter {
            Calendar.current.isDate($0.startDate ?? Date(), inSameDayAs: selectedDay)
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
                HStack {
                    Text("Timetable")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .hAlign(.leading)
                    Button {
                        showingActionSheet = true
                    } label: {
                        Image("createButton")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("Blue"))
                    }
                    .hAlign(.trailing)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 10)
                .background(Color.white.ignoresSafeArea())
                
                VStack(spacing: 0) {
                    DraggableCalendarView(
                        selectedDay: $selectedDay,
                        isBottomSheetOpen: $isBottomSheetOpen,
                        sessions: sessionsList
                    )
                    if filteredSessions.isEmpty {
                        Spacer()
                        Text("No sessions for this day")
                            .font(.system(size: 18))
                            .foregroundColor(Color("Gray"))
                        NavigationLink(destination: {
                            ArchiveView()
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
                                ForEach(filteredSessions) { session in
                                    ActivityPanelView(session: session)
                                        .onTapGesture {
                                            selectedSession = session
                                        }
                                }
                                NavigationLink(destination: {
                                    ArchiveView()
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
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Action"), buttons: [
                    .default(Text("Add Promotion"), action: {
                        selectedSheet = .promotion
                    }),
                    .default(Text("Add Session"), action: {
                        selectedSheet = .activity
                    }),
                    .cancel()
                ])
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView()
                case .activity:
                    NewSessionView()
                }
            }
            .fullScreenCover(isPresented: $isBottomSheetOpen) {
                MonthYearBottomSheetView(
                    selectedDate: $selectedDay,
                    isBottomSheetOpen: $isBottomSheetOpen
                )
            }
            .sheet(item: $selectedSession) { selectedSession in
                SessionDetailsView(session: selectedSession)
            }
        }
    }
}

struct Timetable_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
