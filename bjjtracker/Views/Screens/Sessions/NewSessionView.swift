//
//  NewSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.04.2023.
//

import SwiftUI

struct NewSessionView: View {
    
    typealias Localisation = NewSessionViewViewModel.Localisation
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: NewSessionViewViewModel
    
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
                            dismiss()
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
                            viewModel.saveActivity()
                            dismiss()
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
            viewModel.onAppear()
        }
    }
    
    private var sessionType: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step1SelectType)
            
            SelectionPanelView(
                valuesList: ActivityType.allCases.map { $0.rawValue },
                selectedType: $viewModel.activity.type,
                selectedTypeValue: viewModel.activity.type.rawValue
            )
        }.padding(.top, 10)
    }
    
    private var grapplingStyle: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step2SelectGrapplingStyle)
            SelectionPanelView(
                valuesList: GraplingStyle.allCases.map { $0.rawValue },
                selectedType: $viewModel.activity.style,
                selectedTypeValue: viewModel.activity.style.rawValue
            )
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading) {
            HStack {
                TitleTextView(text: Localisation.step3Duration)
                
                DurationSelectorView(isPickerPresented: $viewModel.isPickerPresented, duration: $viewModel.activity.duration)
            }
            if viewModel.isPickerPresented {
                DurationPicker(duration: $viewModel.activity.duration)
                    .frame(height: 150)
                    .frame(maxWidth: screenWidth)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Blue"), lineWidth: 1))
            }
        }
    }
    
    private var dateAndRepeat: some View {
        VStack(alignment: .leading) {
            TitleTextView(text: Localisation.step4SelectDateAndTime)
            DatePicker("", selection: $viewModel.activity.startDate)
                .datePickerStyle(.compact)
                .fixedSize()
                .offset(x: -2)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(Localisation.repeatSession)
                    Toggle("", isOn: $viewModel.repeatableSessionSettings.isRepeatable.animation(.easeInOut))
                }
                
                // Summary of selection
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color("Blue"))
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(viewModel.repeatableSessionSettings.summaryDescription)
                                .font(.callout)
                                .foregroundStyle(Color("DarkBlue"))
                            let sessionsCountDescription = viewModel.repeatableSessionSettings.sessionsCountDescription(from: viewModel.activity.startDate)
                            if !sessionsCountDescription.isEmpty && viewModel.repeatableSessionSettings.isRepeatable {
                                Text(sessionsCountDescription)
                                    .font(.callout)
                                    .foregroundStyle(Color("Blue"))
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Blue"), lineWidth: 1))

                if viewModel.repeatableSessionSettings.isRepeatable {
                    Divider()
                    
                    Text(Localisation.recurringSectionTitle)
                    HStack {
                        Picker("Recurring", selection: $viewModel.repeatableSessionSettings.repeatType) {
                            ForEach(RepeatType.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .defaultPicker()
                        
                        if viewModel.repeatableSessionSettings.repeatType == .weekly {
                            Picker("RepeatCondition", selection: $viewModel.repeatableSessionSettings.repeatCondition) {
                                ForEach(RepeatCondition.allCases, id: \.self) {
                                    Text($0.title).tag($0)
                                }
                            }
                            .defaultPicker()
                        }
                    }
                    
                    if viewModel.repeatableSessionSettings.repeatType == .weekly {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(Localisation.repeatsEvery)
                            DaysPicker(selectedDays: $viewModel.repeatableSessionSettings.selectedDays)
                        }
                    }
                    
                    Text(Localisation.endCondition)
                        .defaultShadow()
                    HStack {
                        Picker("End condition", selection: $viewModel.repeatableSessionSettings.endCondition) {
                            ForEach(EndCondition.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .defaultPicker()

                        if viewModel.repeatableSessionSettings.endCondition == .onDate {
                            DatePicker("", selection: $viewModel.repeatableSessionSettings.endDate, displayedComponents: [.date])
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
            TextField(Localisation.locationPlaceholder, text: $viewModel.activity.location)
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
            CustomTextEditor(text: $viewModel.activity.notes)
        }
    }
}

struct NewSessionView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            NewSessionView(viewModel: .init(persistanceManager: PersistanceManager(inMemory: true)))
        }
    }
    
    static var previews: some View {
            Container()
                .environmentObject(AppSettings())
                .environmentObject(PersistanceManager(inMemory: true))
    }
}
