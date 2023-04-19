//
//  StatisticsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.04.2023.
//

import SwiftUI
import Introspect

struct StatisticsView: View {
    
    let bgColor: Color = Color("generalBG")
    
    @State private var selectedSegment = 0
    private var segments = ["Week", "Month", "Year"]
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: AppSettings
    
    private var presenter: StatisticsViewPresenter
    
    init(presenter: StatisticsViewPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        
        let totalSessions = presenter.sessionsForInterval().count
        let totalTime = presenter.totalTime()
        VStack {
            if !presenter.isConcreteDates {
                SegmentedPicker(items: segments, selection: $selectedSegment)
                    .padding()
            }
            ScrollView(showsIndicators: false) {
                    VStack {
                        HStack(spacing: 10) {
                            StatsView(text: "Sessions", value: "\(totalSessions)", tendecyGrows: nil, tendecyValue: nil)
                            StatsView(text: "Total time", value: totalTime, tendecyGrows: nil, tendecyValue: nil)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Types of sessions")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("During this period you were great and have finished 133 trainings sessions ")
                                .font(.system(size: 12))
                                .foregroundColor(Color("Gray"))
                        }
                        .hAlign(.leading)
                        .padding(.vertical, 20)
                        
                        InfographicsView(
                            strokeColor: bgColor,
                            statsInfo: [
                                .session: presenter.sessions(by: .session).count,
                                .competition: presenter.sessions(by: .competition).count,
                                .seminar: presenter.sessions(by: .seminar).count
                            ]
                        ).padding(.bottom, 70)
                        
                        Rectangle()
                            .fill(Color("LightGray"))
                            .padding(.horizontal, 20)
                            .frame(height: 1)
                        
                        PieChartView(
                            values: [
                                Double(presenter.sessions(by: .gi).count),
                                Double(presenter.sessions(by: .noGi).count)
                            ],
                            colors: [Color("Blue"), Color("LightBlue")],
                            textColors: [.white, .black],
                            names: ["Gi sessions", "No Gi sessions"],
                            backgroundColor: bgColor, innerRadiusFraction: 0.4
                        )
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                    }
                    .padding(.all, 20)
                    .padding(.bottom, 220)
                }
        }
        .vAlign(.top)
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(presenter.title)
                    .font(.system(size: 20))
                    .fontWeight(.medium)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    hideTabbar(false)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("back")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("Blue"))
                }
            }
        }
        .onAppear {
            hideTabbar(true)
        }
    }
    
    func hideTabbar(_ isHidden: Bool) {
        settings.isTabBarHidden = isHidden
    }
}

struct StatisticsView_Previews: PreviewProvider {
    struct Container: View {
        let settings = AppSettings()
        let interval = DateInterval(start: Date() - TimeInterval(5000 * 60), end: Date())
        
        var body: some View {
            NavigationView {
                StatisticsView(
                    presenter: StatisticsViewPresenter(dateInterval: interval)
                )
                .environmentObject(settings)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
