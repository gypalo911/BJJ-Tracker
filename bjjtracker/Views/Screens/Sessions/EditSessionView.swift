//
//  EditSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI
import CoreData

struct EditSessionView: View {
    
    @State private var isPickerPresented = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment (\.managedObjectContext) var managedObjContext
    
    var session: Session
    
    @StateObject var activity: Activity
    
    var onDismiss: ((Session) -> Void)?
    
    func update(_ session: Session) {
        PersistanceManager.shared.edit(
            session: session,
            activity: activity,
            context: managedObjContext
        )
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "1. Select type:")

                                SelectionPanelView(
                                    g: geometry,
                                    valuesList: ActivityType.allCases.map { $0.rawValue },
                                    selectedType: $activity.type,
                                    selectedTypeValue: activity.type.rawValue
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "2. Select grappling style:")
                                SelectionPanelView(
                                    g: geometry,
                                    valuesList: GraplingStyle.allCases.map { $0.rawValue },
                                    selectedType: $activity.style,
                                    selectedTypeValue: activity.style.rawValue
                                )
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "3. Select date and time:")
                                DatePicker("", selection: $activity.startDate)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "4. Duration:")

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
                                TitleTextView(text: "Location:")
                                TextField("Location...", text: $activity.location)
                                    .frame(maxHeight: 50, alignment: .top)
                                    .padding(20)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LightBlue"))
                                    }
                                    .padding(.leading, 5)
                            }
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Notes")
                                TextField("Add some details...", text: $activity.notes)
                                    .frame(minHeight: 150, alignment: .top)
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("LightBlue"))
                                    ).padding(.leading, 5)
                            }
                        }
                        
                        Button(action: {
                            
                        }, label: {
                            Text("Delete")
                                .foregroundColor(.red)
                        })
                        .padding(.vertical, 20)
                        .hAlign(.center)
                    }
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Edit Session")
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
                                update(session)
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
            }.onAppear {
//                if let filledActivity = Activity.from(session: session) {
//                    activity = filledActivity
//                }
            }
        }
    }
}

//struct EditSessionView_Previews: PreviewProvider {
//    struct Container: View {
//        @State var activity: Activity = .init(type: .training, style: .gi, duration: 0, startDate: Date(), location: "", notes: "")
//
//        var body: some View {
//            EditSessionView(presenter: EditSessionPresenter(activity: activity))
//        }
//    }
//
//    static var previews: some View {
//        Container()
//    }
//}
