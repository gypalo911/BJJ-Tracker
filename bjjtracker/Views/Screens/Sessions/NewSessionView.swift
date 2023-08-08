//
//  NewSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.04.2023.
//

import SwiftUI

struct NewSessionView: View {
    
    @StateObject var viewModel: NewSessionViewViewModel
    
    @State private var isPickerPresented = false
    
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @Environment(\.presentationMode) var presentationMode
    @Environment (\.managedObjectContext) var managedObjContext
    
    @StateObject var activity: Activity = .init(type: .training, style: .gi, duration: 0, startDate: Date(), location: "", notes: "")
    
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
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Select type:".localizedString)

                                SelectionPanelView(
                                    valuesList: ActivityType.allCases.map { $0.rawValue },
                                    selectedType: $activity.type,
                                    selectedTypeValue: activity.type.rawValue
                                )
                            }.padding(.top, 10)

                            VStack(alignment: .leading) {
                                TitleTextView(text: "2. Select grappling style:".localizedString)
                                SelectionPanelView(
                                    valuesList: GraplingStyle.allCases.map { $0.rawValue },
                                    selectedType: $activity.style,
                                    selectedTypeValue: activity.style.rawValue
                                )
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "3. Select date and time:".localizedString)
                                DatePicker("", selection: $activity.startDate)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "4. Duration:".localizedString)

                                DurationSelectorView(isPickerPresented: $isPickerPresented, duration: $activity.duration)
                                if isPickerPresented {
                                    DurationPicker(duration: $activity.duration)
                                        .frame(height: 150)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Location:".localizedString)
                                TextField("Location...".localizedString, text: $activity.location)
                                    .padding(20)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LightBlue"))
                                    }
                                    .padding(.leading, 5)
                            }
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Notes".localizedString)
                                CustomTextEditor(text: $activity.notes)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .navigationTitle("Create Session".localizedString)
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
                                Text("Save")
                                    .fixedSize()
                                    .foregroundColor(Color("Blue"))
                            }
                        }
                    }
                }
        }
    }
    
    func save() {
        persistanceManager.createSession(from: activity, context: managedObjContext)
        viewModel.sessionCreated(from: activity)
    }
}

struct NewSessionView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            NewSessionView(viewModel: .init())
        }
    }
    
    static var previews: some View {
        ForEach(["iPhone 14", "iphone 7 ios 15"], id: \.self) { (device) in
            Container()
                .environmentObject(AppSettings())
                .previewDevice(PreviewDevice(rawValue: device))
                .previewDisplayName(device)
        }
    }
}
