//
//  ArchiveView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI
import Introspect

struct ArchiveView: View {
    
    @State private var selectedActivity: Activity?
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    var activities: [Activity]
    
    private var groupedItems: Dictionary<Date, [Activity]> {
        return Dictionary(grouping: activities, by: {
            Calendar.current.startOfDay(for: $0.startDate)
        })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(groupedItems.keys.sorted(), id: \.self) { key in
                    Text("\(key.toString("dd MMMM YYYY"))")
                        .hAlign(.leading)
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 10)
                    ForEach(groupedItems[key]!) { activity in
                        ActivityPanelView(activity: activity)
                            .onTapGesture {
                                self.selectedActivity = activity
                            }
                    }
                }
            }
            .sheet(item: $selectedActivity) { selectedActivity in
                SessionDetailsView(activity: selectedActivity)
            }
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
            }
            .onAppear {
                settings.isTabBarHidden = true
            }
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        settings.isTabBarHidden = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: {
                        StatisticsView()
                    }) {
                        Image("stats")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image("calendar")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    }
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        let activ = [
            Activity(type: .seminar, style: .noGi, duration: 120, startDate: Date() - TimeInterval(2000 * 60), location: "Lutsk", notes: "Some notes"),
            Activity(type: .session, style: .gi, duration: 90, startDate: Date() - 60 * 60, location: "Lutsk", notes: "Some notes"),
            Activity(type: .competition, style: .noGi, duration: 90, startDate: Date() + TimeInterval(1000 * 60), location: "Lutsk", notes: "Some notes"),
        ]
        ArchiveView(activities: activ)
    }
}
