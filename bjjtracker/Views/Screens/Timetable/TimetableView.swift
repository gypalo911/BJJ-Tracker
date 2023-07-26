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
    @State var selectedSheet: ModalsSheets?
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
            if let session = selectedSession {
                SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session), dismissCallback: {
                    withAnimation(AppConstants.mgeAnimation) {
                        selectedSession = nil
                    }
                })
            } else {
                NavigationView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Timetable")
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .hAlign(.leading)
                            Button {
                                settings.showingActionSheet = true
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
                                    ArchiveView(viewModel: .init(persistanceManager: persistanceManager))
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
                                            ActivityPanelView(session: session, namespace: namespace)
                                                .onTapGesture {
                                                    withAnimation(AppConstants.mgeAnimation) {
                                                        selectedSession = session
                                                    }
                                                }
                                        }
                                        NavigationLink(destination: {
                                            ArchiveView(viewModel: .init(persistanceManager: persistanceManager))
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
                    .fullScreenCover(isPresented: $isBottomSheetOpen) {
                        MonthYearBottomSheetView(
                            selectedDate: $selectedDay,
                            isBottomSheetOpen: $isBottomSheetOpen
                        )
                    }
                    .onAppear {
                        viewModel.onTimetableViewAppeared()
                        changeNavBar(.clear)
                        settings.isTabBarHidden = false
                    }
                }
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
