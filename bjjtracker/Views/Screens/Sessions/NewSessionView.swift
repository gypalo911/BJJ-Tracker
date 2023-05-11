//
//  NewSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.04.2023.
//

import SwiftUI

struct NewSessionView: View {
    
    @State private var isPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment (\.managedObjectContext) var managedObjContext
    
    @StateObject var activity: Activity = .init(type: .training, style: .gi, duration: 0, startDate: Date(), location: "", notes: "")
    
    @EnvironmentObject var activitiesManager: ActivitiesManager
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Select type:".localizedString)

                                SelectionPanelView(
                                    g: geometry,
                                    valuesList: ActivityType.allCases.map { $0.rawValue },
                                    selectedType: $activity.type,
                                    selectedTypeValue: activity.type.rawValue.localizedString
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "2. Select grappling style:".localizedString)
                                SelectionPanelView(
                                    g: geometry,
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
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Create Session".localizedString)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
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
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("Save")
                                    .fixedSize()
                                    .foregroundColor(Color("Blue"))
                            }
                        }
                    }
                    .vAlign(.top)
                }
            }
        }
    }
    
    func save() {
        PersistanceManager.shared.createSession(from: activity, context: managedObjContext)
    }
}

struct NewSessionView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            NewSessionView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}
