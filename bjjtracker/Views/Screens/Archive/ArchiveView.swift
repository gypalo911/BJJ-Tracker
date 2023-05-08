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
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) private var viewContext
    @SectionedFetchRequest<String, Session>(sectionIdentifier: \.startDateString, sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)], animation: .easeInOut) var sessions: SectionedFetchResults<String, Session>
    
    @State var selectedSession: Session?
    
    @State var showDetailsView: Bool = false
    
    func group(_ result: FetchedResults<Session>) -> Dictionary<Date, [Session]> {
        Dictionary(grouping: result, by: {
            Calendar.current.startOfDay(for: $0.startDate!)
        })
    }
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                ForEach(sessions, id: \.id) { section in
                    Text("\(section.id)")
                        .hAlign(.leading)
                        .padding([.horizontal, .top], 20)
                        .padding(.bottom, 10)
                    ForEach(section) { session in
                        ActivityPanelView(session: session)
                            .onTapGesture {
                                selectedSession = session
                                showDetailsView = true
                            }
                    }
                }
            }
            .onAppear {
                settings.isTabBarHidden = true
            }
            .sheet(isPresented: $showDetailsView) {
                if let selectedSession = selectedSession {
                    SessionDetailsView(session: selectedSession, dismissCallback: {})
                }
            }
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
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
                    //                    if let start = activities.keys.min()?.startOfDay,
                    //                       let end = activities.keys.max()?.endOfDay {
                    //                        NavigationLink(destination: {
                    //                            StatisticsView(
                    //                                presenter: StatisticsViewPresenter(dateInterval: DateInterval(start: start, end: end))
                    //                            )
                    //                        }) {
                    //                            Image("stats")
                    //                                .resizable()
                    //                                .frame(width: 25, height: 25)
                    //                                .foregroundColor(Color("Blue"))
                    //                        }
                    //                    }
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
