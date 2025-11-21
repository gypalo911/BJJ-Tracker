//
//  NewSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.04.2023.
//

import SwiftUI

enum RepeatType: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
    
    var title: String {
        self.rawValue.localizedString
    }
}

enum RepeatCondition: String, CaseIterable, Identifiable {
    case every1Week = "Every Week"
    case every2Weeks = "Every 2 Weeks"
    
    var id: String { self.rawValue }
    
    var title: String {
        self.rawValue.localizedString
    }
}

enum EndCondition: String, CaseIterable, Identifiable {
    case never = "Never"
    case onDate = "On date"
    
    var id: String { self.rawValue }
    
    var title: String {
        self.rawValue.localizedString
    }
}


class RecurringSettings: ObservableObject {
    @Published var isRepeatable: Bool = true
    @Published var repeatType: RepeatType = .weekly
    @Published var repeatCondition: RepeatCondition = .every1Week
    @Published var selectedDays: [DaysPicker.Day] = []
    @Published var endCondition: EndCondition = .never
    @Published var endDate: Date = Date()
    
    var summaryDescription: String {
        guard isRepeatable else { return "Does not repeat".localizedString }

        switch repeatType {
        case .weekly:
            let interval: String = repeatCondition.title

            let dayTitles = selectedDays
                .sorted { $0.rawValue < $1.rawValue }
                .map { $0.localizedTitle }
                .joined(separator: ", ")

            let base = dayTitles.isEmpty ? interval : interval + " on " + dayTitles

            switch endCondition {
            case .never:
                return base
            case .onDate:
                let formattedDate = endDate.formatted(.dateTime.year().month(.wide).day())
                return base + " until " + formattedDate
            }

        case .monthly:
            let base = "Every month".localizedString
            switch endCondition {
            case .never:
                return base
            case .onDate:
                let formattedDate = endDate.formatted(.dateTime.year().month(.wide).day())
                return base + " until " + formattedDate
            }
        }
    }

    // Placeholder: without business rules for generating occurrences, we expose a string hook.
    // Replace the implementation once occurrence generation is available.
    var sessionsCountDescription: String {
        // TODO: compute actual number of sessions based on rules and a range
        return "" // Return empty when unknown
    }
}

struct NewSessionView: View {
    
    @EnvironmentObject var settings: AppSettings
    
    @StateObject var viewModel: NewSessionViewViewModel
    
    @State private var isPickerPresented = false
    @ObservedObject private var recurringSettings: RecurringSettings = .init()
    
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjContext
    
    @StateObject var activity: Activity = .init(type: .training, style: .gi, duration: 60, startDate: Date(), location: "", notes: "")
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    
    init(viewModel: NewSessionViewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        sessionType
                        
                        grapplingStyle
                        durationSection
                        dateAndRepeat
                    }
                    
                    Group {
                        locationSection
                        notesSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .navigationTitle(Localisation.newSession)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            viewModel.popupDismissed()
                        } label: {
                            Image("back")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("Blue"))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            save()
                            NotificationManager.shared.scheduleNotification(activity: activity)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text(Localisation.save)
                                .fixedSize()
                                .foregroundColor(Color("Blue"))
                        }
                    }
                }
            }
        }
        .onAppear {
            activity.startDate = settings.selectedCalendarDate

            if let selectedDay = DaysPicker.Day(rawValue: Date().dayNumberOfWeek() ?? 0), recurringSettings.selectedDays.isEmpty {
              recurringSettings.selectedDays = [selectedDay]
            }
        }
    }
    
    private var sessionType: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step1SelectType)
            
            SelectionPanelView(
                valuesList: ActivityType.allCases.map { $0.rawValue },
                selectedType: $activity.type,
                selectedTypeValue: activity.type.rawValue
            )
        }.padding(.top, 10)
    }
    
    private var grapplingStyle: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step2SelectGrapplingStyle)
            SelectionPanelView(
                valuesList: GraplingStyle.allCases.map { $0.rawValue },
                selectedType: $activity.style,
                selectedTypeValue: activity.style.rawValue
            )
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step3Duration)

            DurationSelectorView(isPickerPresented: $isPickerPresented, duration: $activity.duration)
            if isPickerPresented {
                DurationPicker(duration: $activity.duration)
                    .frame(height: 150)
                    .frame(maxWidth: screenWidth)
            }
        }
    }
    
    private var dateAndRepeat: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step4SelectDateAndTime)
            DatePicker("", selection: $activity.startDate)
                .datePickerStyle(.compact)
                .fixedSize()
                .offset(x: -2)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(Localisation.repeatSession)
                    Toggle("", isOn: $recurringSettings.isRepeatable.animation(.easeInOut))
                }
                
                // Summary of selection
                Text(recurringSettings.summaryDescription)
                    .font(.callout)
                    .foregroundColor(Color("Blue"))

                if recurringSettings.isRepeatable {
                    Divider()
                    
                    Text(Localisation.recurringSectionTitle)
                    HStack {
                        Picker("Recurring", selection: $recurringSettings.repeatType) {
                            ForEach(RepeatType.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .defaultPicker()
                        
                        if recurringSettings.repeatType == .weekly {
                            Picker("RepeatCondition", selection: $recurringSettings.repeatCondition) {
                                ForEach(RepeatCondition.allCases, id: \.self) {
                                    Text($0.title).tag($0)
                                }
                            }
                            .defaultPicker()
                        }
                    }
                    
                    if recurringSettings.repeatType == .weekly {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(Localisation.repeatsEvery)
                            DaysPicker(selectedDays: $recurringSettings.selectedDays)
                        }
                    }

                    if !recurringSettings.sessionsCountDescription.isEmpty {
                        Text(recurringSettings.sessionsCountDescription)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(Localisation.endCondition)
                        .defaultShadow()
                    HStack {
                        Picker("End condition", selection: $recurringSettings.endCondition) {
                            ForEach(EndCondition.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .defaultPicker()

                        if recurringSettings.endCondition == .onDate {
                            DatePicker("", selection: $recurringSettings.endDate, displayedComponents: [.date])
                                .datePickerStyle(.automatic)
                        }
                    }
                }

            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 0.5)
                    .fill(Color("Blue"))
            )
            .padding(.vertical, 20)
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.locationTitle)
            TextField(Localisation.locationPlaceholder, text: $activity.location)
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("LightBlue"))
                }
                .padding(.leading, 5)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.notesTitle)
            CustomTextEditor(text: $activity.notes)
        }
    }

    func save() {
        persistanceManager.createSession(from: activity)
        viewModel.sessionCreated(from: activity)
    }
}

extension NewSessionView {
    enum Localisation {
        static var newSession: String { "New Session".localizedString }

        // Step titles
        static var step1SelectType: String { "1. " + "Select type:".localizedString }
        static var step2SelectGrapplingStyle: String { "2. " + "Select grappling style:".localizedString }
        static var step3Duration: String { "3. " + "Duration:".localizedString }
        static var step4SelectDateAndTime: String { "4. " + "Select date and time:".localizedString }

        // Recurring/Repeat section
        static var repeatSession: String { "Repeat session".localizedString }
        static var recurringSectionTitle: String { "Recurring".localizedString }
        static var repeatsEvery: String { "Repeats every:".localizedString }
        static var endCondition: String { "End condition".localizedString }

        // Duration and controls
        static var save: String { "Save".localizedString }

        // Form fields
        static var locationTitle: String { "Location:".localizedString }
        static var locationPlaceholder: String { "Location...".localizedString }
        static var notesTitle: String { "Notes".localizedString }
    }
}

struct NewSessionView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            NewSessionView(viewModel: .init())
        }
    }
    
    static var previews: some View {
            Container()
                .environmentObject(AppSettings())
    }
}
