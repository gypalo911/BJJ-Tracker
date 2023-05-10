//
//  StatisticsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.04.2023.
//

import SwiftUI
import Introspect

enum CalendarSegment: Int {
    case week
    case month
    case year
}

struct StatisticsView: View {
    
    let bgColor: Color = Color("generalBG")
    
    @State private var selectedSegment: Int = CalendarSegment.week.rawValue
    private var segments = ["Week", "Month", "Year"]
    
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
    
    @EnvironmentObject var settings: AppSettings
    
    @State var title: String = ""
    @State var dateInterval: DateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
    
    private var presenter: StatisticsViewPresenter
    
    private var filteredSession: [Session] {
        return sessionsList.filter {
            (dateInterval.start...dateInterval.end).contains($0.startDate ?? Date())
        }
    }
    
    init(presenter: StatisticsViewPresenter) {
        self.presenter = presenter
        let interval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
        
        self.dateInterval = interval
    }
    
    func totalTime() -> String {
        return filteredSession.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
    }
    
    func sessions(by type: ActivityType) -> [Session] {
        return filteredSession.filter({ $0.activityType == type })
    }
    
    func sessions(by style: GraplingStyle) -> [Session] {
        return filteredSession.filter({ $0.activityStyle == style })
    }
    
    func initDates() {
        if selectedSegment == 0 {
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!
            let end = Date().startOfDay
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let start = Date().startOfMonth()
            let end = Date().endOfMonth()
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            let currentYearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: dateInterval.start)))!
            var currentYearEnd = Calendar.current.date(byAdding: .year, value: 1, to: currentYearStart)!
            currentYearEnd = Calendar.current.date(byAdding: .minute, value: -1, to: currentYearEnd)!
            dateInterval = DateInterval(start: currentYearStart, end: currentYearEnd)
        }
    }
    
    func plusWeek() {
        if selectedSegment == 0 {
            let start = dateInterval.end
            let end = Calendar.current.date(byAdding: .day, value: 7, to: dateInterval.end)!
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let start = Calendar.current.date(byAdding: .month, value: 1, to: dateInterval.end.startOfMonth())!
            let end = Calendar.current.date(byAdding: .month, value: 1, to: dateInterval.end.endOfMonth())!
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            initDates()
            let start = Calendar.current.date(byAdding: .year, value: 1, to: dateInterval.start)!
            let end = Calendar.current.date(byAdding: .year, value: 1, to: dateInterval.end)!
            dateInterval = DateInterval(start: start, end: end)
        }
        setupTitle()
    }
    
    func minusWeek() {
        if selectedSegment == 0 {
            let start = Calendar.current.date(byAdding: .day, value: -7, to: dateInterval.start)!
            let end = dateInterval.start
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let startOfMonth = dateInterval.start.startOfMonth()
            let start = Calendar.current.date(byAdding: .month, value: -1, to: startOfMonth)!
            let end = start.endOfMonth()
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            initDates()
            let start = Calendar.current.date(byAdding: .year, value: -1, to: dateInterval.start)!
            let end = Calendar.current.date(byAdding: .minute, value: -1, to: dateInterval.start)!
            dateInterval = DateInterval(start: start, end: end)
        }
        setupTitle()
    }
    
    func setupTitle() {
        title = presenter.intervalToString(from: dateInterval.start, to: dateInterval.end, segment: selectedSegment)
    }
    
    var body: some View {
        
        let totalSessions = filteredSession.count
        let totalTime = totalTime()
        
        VStack {
            Text("Statistics")
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding([.leading, .top], 20)
                .hAlign(.leading)
                .background(Color.clear.ignoresSafeArea())
            if !presenter.isConcreteDates {
                SegmentedPicker(
                    items: segments,
                    selection: $selectedSegment,
                    onChanged: { index in
                        selectedSegment = index
                        initDates()
                        setupTitle()
                    }
                )
                .padding([.leading, .trailing, .bottom], 20)
            }
            HStack(spacing: 30) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        minusWeek()
                    }
                }, label: {
                    Image.init(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .foregroundColor(Color("Blue"))
                })
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color("Gray"))
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        plusWeek()
                    }
                }, label: {
                    Image.init(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .foregroundColor(Color("Blue"))
                })
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
                    }
                    .hAlign(.leading)
                    .padding(.vertical, 20)
                    
                    InfographicsView(
                        strokeColor: bgColor,
                        statsInfo: [
                            .training: sessions(by: .training).count,
                            .competition: sessions(by: .competition).count,
                            .seminar: sessions(by: .seminar).count
                        ]
                    ).padding(.bottom, 70)
                    
                    Rectangle()
                        .fill(Color("LightGray"))
                        .padding(.horizontal, 20)
                        .frame(height: 1)
                    
                    if sessions(by: .gi).count > 0 || sessions(by: .noGi).count > 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sessions by grapling style")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        .hAlign(.leading)
                        .padding(.vertical, 20)
                        
                        PieChartView(
                            values: [
                                Double(sessions(by: .gi).count),
                                Double(sessions(by: .noGi).count)
                            ],
                            colors: [Color("Blue"), Color("LightBlue")],
                            textColors: [.white, .black],
                            names: ["Gi sessions", "No Gi sessions"],
                            backgroundColor: bgColor, innerRadiusFraction: 0.4
                        )
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.all, 20)
                .padding(.bottom, 300)
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
                Text(title)
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
            hideTabbar(false)
            self.title = presenter.intervalToString(from: dateInterval.start, to: dateInterval.end, segment: selectedSegment)
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
            //            NavigationView {
            StatisticsView(presenter: StatisticsViewPresenter(dateInterval: interval))
                .environmentObject(settings)
            //            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
