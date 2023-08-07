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
    
    private var segments = [
        "Week".localizedString,
        "Month".localizedString,
        "Year".localizedString
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
    
    @EnvironmentObject var settings: AppSettings
    
    @ObservedObject var viewModel: StatisticsViewViewModel
    
    private var filteredSessions: [Session] {
        return sessionsList.filter {
            ($0.startDate ?? Date()).isInInterval(dateInterval: viewModel.dateInterval)
        }
    }
    
    init(viewModel: StatisticsViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            Text("Statistics")
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 10)
                .hAlign(.leading)
                .background(Color.clear.ignoresSafeArea())
            if !viewModel.isConcreteDates {
                SegmentedPicker(
                    items: segments,
                    selection: $viewModel.selectedSegment,
                    onChanged: { index in
                        viewModel.selectSegment(segment: index)
                    }
                )
                .padding([.leading, .trailing, .bottom], 20)
            }
            HStack(spacing: 30) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        viewModel.minusInterval()
                    }
                }, label: {
                    Image.init(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                        .foregroundColor(Color("Blue"))
                })
                Text(viewModel.title)
                    .font(.system(size: 16))
                    .fontWeight(.regular)
                    .foregroundColor(Color.black)
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        viewModel.plusInterval()
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
                        StatsView(text: "Sessions".localizedString, value: "\(filteredSessions.count)")
                        StatsView(text: "Total time".localizedString, value: viewModel.totalTime(filteredSessions))
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
                            .training: viewModel.sessions(by: .training, filteredSessions).count,
                            .competition: viewModel.sessions(by: .competition, filteredSessions).count,
                            .seminar: viewModel.sessions(by: .seminar, filteredSessions).count
                        ]
                    ).padding(.bottom, 70)
                    
                    Rectangle()
                        .fill(Color("LightGray"))
                        .padding(.horizontal, 20)
                        .frame(height: 1)
                    
                    if viewModel.sessions(by: .gi, filteredSessions).count > 0 ||
                        viewModel.sessions(by: .noGi, filteredSessions).count > 0
                    {
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
                                Double(viewModel.sessions(by: .gi, filteredSessions).count),
                                Double(viewModel.sessions(by: .noGi, filteredSessions).count)
                            ],
                            colors: [Color("Blue"), Color("LightBlue")],
                            textColors: [.white, .black],
                            names: ["Gi sessions".localizedString, "No Gi sessions".localizedString],
                            backgroundColor: bgColor, innerRadiusFraction: 0.4
                        )
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.all, 20)
                .padding(.bottom, 350)
            }
        }
        .vAlign(.top)
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.title)
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
            viewModel.setupTitle()
            viewModel.onStatisticsViewAppeared()
        }
    }
    
    func hideTabbar(_ isHidden: Bool) {
        settings.isTabBarHidden = isHidden
    }
}

struct StatisticsView_Previews: PreviewProvider {
    struct Container: View {
        let interval = DateInterval(start: Date() - TimeInterval(5000 * 60), end: Date())
        
        var body: some View {
            StatisticsView(viewModel: StatisticsViewViewModel(dateInterval: interval))
        }
    }
    
    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .environmentObject(AppSettings())
    }
}
