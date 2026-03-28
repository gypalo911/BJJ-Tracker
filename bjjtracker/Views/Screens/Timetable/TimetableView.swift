//
//  TimetableView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TimetableView: View {
    enum Localisation {
        static let timetable = "Timetable"
        static let emptyDay = "No sessions for this day"
        static let viewHistory = "View History"
    }
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @ObservedObject var viewModel: TimetableViewViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessionsList: FetchedResults<SessionEntity>
    
    @State var selectedDay: Date = Date()
    @State var selectedSheet: ModalSheets?
    @State var isCalendarBottomSheetOpen: Bool = false
    
    @State var selectedSession: SessionEntity?
    
    @Namespace var namespace
    
    private var filteredSessions: [SessionEntity] {
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
                    Text(Localisation.timetable.localizedString)
                        .font(token: DesignSystem.shared.fonts.title, weight: .bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                        .hAlign(.leading)
                        .background(Color.white.ignoresSafeArea())
                    
                    VStack(spacing: 0) {
                        DraggableCalendarView(
                            selectedDay: $selectedDay,
                            isBottomSheetOpen: $isCalendarBottomSheetOpen,
                            sessions: sessionsList
                        )
                        if filteredSessions.isEmpty {
                            Spacer()
                            Text(Localisation.emptyDay.localizedString)
                                .font(token: DesignSystem.shared.fonts.body)
                                .foregroundColor(DesignSystem.shared.colors.gray)
                            NavigationLink(destination: {
                                JournalView(viewModel: .init(persistanceManager: persistanceManager))
                            }) {
                                HStack {
                                    Text(Localisation.viewHistory.localizedString)
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
                                        let sessionId = session.id?.uuidString ?? ""
                                        if selectedSession == nil {
                                            ActivityPanelView(session: session)
                                                .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace)
                                                .onTapGesture {
                                                    withAnimation(AppConstants.mgeAnimation) {
                                                        selectedSession = session
                                                    }
                                                }
                                        } else {
                                            ActivityPanelView(session: session)
                                        }
                                    }
                                    NavigationLink(destination: {
                                        JournalView(viewModel: .init(persistanceManager: persistanceManager))
                                    }) {
                                        HStack {
                                            Text(Localisation.viewHistory.localizedString)
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
                .background(DesignSystem.shared.colors.generalBackground.ignoresSafeArea())
                .backport.hiddenToolbar(true)
                .onChange(of: selectedDay) { _, value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isCalendarBottomSheetOpen = false
                    }
                    settings.selectedCalendarDate = value.setCurrentTime()
                }
                .onChange(of: isCalendarBottomSheetOpen) { _, value in
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
            .bottomSheet(isPresented: $isCalendarBottomSheetOpen) {
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
                SessionDetailsView(
                    namespace: namespace,
                    viewModel: SessionDetailsViewModel(
                        session: session,
                        persistanceManager: persistanceManager,
                        notificationManager: NotificationManager(),
                        dismissCallback: {
                            withAnimation(AppConstants.mgeAnimation) {
                                selectedSession = nil
                                settings.isTabBarHidden = false
                            }
                        }
                    )
                ).zIndex(1)
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
