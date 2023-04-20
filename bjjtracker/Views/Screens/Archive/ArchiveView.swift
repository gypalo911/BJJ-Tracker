//
//  ArchiveView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI
import Introspect

struct ArchiveView: View {
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var activitiesManager: ActivitiesManager
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var presenter: ArchivePresenter = ArchivePresenter()
    
    @State var selectedActivity: Activity?
    
    @State var showDetailsView: Bool = false
    
    var body: some View {

        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(activitiesManager.groupedActivities.keys.sorted(by: { $0 > $1 }), id: \.self) { key in
                        Text("\(key.toString("dd MMMM YYYY"))")
                            .hAlign(.leading)
                            .padding([.horizontal, .top], 20)
                            .padding(.bottom, 10)
                        ForEach(activitiesManager.groupedActivities[key]!) { activity in
                            ActivityPanelView(activity: activity)
                                .onTapGesture {
                                    showDetailsView = true
                                    selectedActivity = activity
                                }
                        }
                    }
                }.id(UUID())
            }
            .sheet(isPresented: $showDetailsView) {
                if let selectedActivity = selectedActivity {
                    SessionDetailsView(activity: selectedActivity, dismissCallback: {
//                        presenter.groupedItems = [:]
//                        presenter.fetchItems()
                    })
                }
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
                    if let start = activitiesManager.groupedActivities.keys.min()?.startOfDay,
                       let end = activitiesManager.groupedActivities.keys.max()?.endOfDay {
                        NavigationLink(destination: {
                            StatisticsView(
                                presenter: StatisticsViewPresenter(dateInterval: DateInterval(start: start, end: end))
                            )
                        }) {
                            Image("stats")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("Blue"))
                        }
                    }
                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//
//                    } label: {
//                        Image("calendar")
//                            .resizable()
//                            .frame(width: 25, height: 25)
//                            .foregroundColor(Color("Blue"))
//                    }
//                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView()
    }
}
