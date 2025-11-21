//
//  EditSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI

struct EditSessionView: View {
    
    @StateObject var viewModel: EditSessionViewViewModel
    
    @State private var isPickerPresented = false
    
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    @Environment(\.presentationMode) var presentationMode
    
    var session: Session
    
    @StateObject var activity: Activity
    
    var onDismiss: ((Session?) -> Void)?
    
    func update(_ session: Session) {
        persistanceManager.edit(
            session: session,
            activity: activity
        )
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Select type:".localizedString)

                                SelectionPanelView(
//                                    geometry: geometry,
                                    valuesList: ActivityType.allCases.map { $0.rawValue },
                                    selectedType: $activity.type,
                                    selectedTypeValue: activity.type.rawValue
                                )
                            }.padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Select grappling style:".localizedString)
                                SelectionPanelView(
//                                    geometry: geometry,
                                    valuesList: GraplingStyle.allCases.map { $0.rawValue },
                                    selectedType: $activity.style,
                                    selectedTypeValue: activity.style.rawValue
                                )
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Select date and time:".localizedString)
                                DatePicker("", selection: $activity.startDate)
                                    .datePickerStyle(.compact)
                                    .fixedSize()
                                    .offset(x: -2)
                            }
                            VStack(alignment: .leading) {
                                TitleTextView(text: "Duration:".localizedString)

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
                        
//                        Button(action: {
//                            viewModel.sessionDeleted(activity)
//                            persistanceManager.delete(session: session, context: managedObjContext)
//                            NotificationManager.shared.removePendingNotificationRequests(with: [String(describing: session.id)])
//                            presentationMode.wrappedValue.dismiss()
//                            onDismiss?(nil)
//                        }, label: {
//                            Text("Delete")
//                                .foregroundColor(.red)
//                        })
//                        .padding(.vertical, 20)
//                        .hAlign(.center)
                    }
                    .hAlign(.leading)
                    .padding(.horizontal, 20)
                    .navigationTitle("Edit Session".localizedString)
                    .onAppear {
                        viewModel.onScreenAppeared()
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewModel.popupDismissed()
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
                                viewModel.sessionEdited(activity)
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
            }
        }
    }
}

struct EditSessionView_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>

        var body: some View {
            let session: Session = sessionsList.map { $0 }.first!
            EditSessionView(
                viewModel: .init(),
                session: session,
                activity: Activity.from(session: session)!,
                onDismiss: { _ in }
            )
        }
    }

    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
