//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @ObservedObject var viewModel: TimetableViewViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessionsList: FetchedResults<Session>
    
    @State var selectedDay: Date = Date()
    @State var selectedSheet: ModalSheets?
    @State var isBottomSheetOpen: Bool = false
    
    @State var selectedSession: Session?
    
    @Namespace var namespace
    
    private var filteredSessions: [Session] {
        sessionsList.filter {
            Calendar.current.isDate($0.startDate ?? Date(), inSameDayAs: selectedDay)
        }
    }
    
    init(viewModel: TimetableViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    Text("Timetable")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .padding(.top, UIScreen.main.bounds.size.width <= 375 ? 30 : 60)
                        .hAlign(.leading)
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
                                .font(.body)
                                .foregroundColor(Color("Gray"))
                            NavigationLink(destination: {
                                JournalView(viewModel: .init(persistanceManager: persistanceManager))
                            }) {
                                HStack {
                                    Text("View History")
                                        .font(.callout)
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
                                        ActivityPanelView(session: session, namespace: namespace)
                                            .onTapGesture {
                                                withAnimation(AppConstants.mgeAnimation) {
                                                    selectedSession = session
                                                }
                                            }
                                    }
                                    NavigationLink(destination: {
                                        JournalView(viewModel: .init(persistanceManager: persistanceManager))
                                    }) {
                                        HStack {
                                            Text("View History")
                                                .font(.callout)
                                                .foregroundColor(.blue)
                                            Image("archive")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                    .padding(.top, 20)
                                }
                                .padding(.bottom, 150)
                                .padding(.top, 20)
                            }
                        }
                    }
                    .padding(.top, -10)
                }
                .vAlign(.top)
                .background(Color("generalBG").ignoresSafeArea())
                .backport.hiddenToolbar(true)
                .onChange(of: selectedDay, perform: { value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isBottomSheetOpen = false
                    }
                    settings.selectedCalendarDate = value.setCurrentTime()
                })
                .onChange(of: isBottomSheetOpen) { value in
                    if value {
                        settings.isTabBarHidden = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            settings.isTabBarHidden = false
                        }
                    }
                }
                .onAppear {
                    viewModel.onTimetableViewAppeared()
                    changeNavBar(.clear)
                    settings.isTabBarHidden = false
                    settings.selectedCalendarDate = selectedDay.setCurrentTime()
                }
            }
            .bottomSheet(isPresented: $isBottomSheetOpen) {
                DatePicker(
                    "Start Date",
                    selection: $selectedDay,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .datePickerStyle(.graphical)
                .background(Color.white)
                .padding([.horizontal, .top], 20)
            }
            .zIndex(0)
            
            if let session = selectedSession {
                SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session), dismissCallback: {
                    withAnimation(AppConstants.mgeAnimation) {
                        selectedSession = nil
                        settings.isTabBarHidden = false
                    }
                }).zIndex(1)
            }
        }
    }
}

struct Timetable_Previews: PreviewProvider {
    static var previews: some View {
        TimetableView(viewModel: .init())
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
