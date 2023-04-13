//
//  StatisticsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.04.2023.
//

import SwiftUI
import Introspect

struct StatisticsView: View {
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSegment = 0
    
    private var segments = ["Week", "Month", "Year"]
    
    let bgColor: Color = Color("generalBG")
    
    var body: some View {
        VStack {
            SegmentedPicker(items: segments, selection: $selectedSegment)
                .padding()
            ScrollView(showsIndicators: false) {
                    VStack {
                        HStack(spacing: 10) {
                            StatsView(text: "Sessions", value: "3", tendecyGrows: true, tendecyValue: "2")
                            StatsView(text: "Total time", value: "25h", tendecyGrows: false, tendecyValue: "1h 20m")
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
                            statsInfo: [.session: 12, .competition: 5, .seminar: 3]
                        ).padding(.bottom, 70)
                        
                        Rectangle()
                            .fill(Color("LightGray"))
                            .padding(.horizontal, 20)
                            .frame(height: 1)
                        
                        PieChartView(values: [12, 6], colors: [Color("Blue"), Color("LightBlue")], textColors: [.white, .black], names: ["Gi sessions", "No Gi sessions"], backgroundColor: bgColor, innerRadiusFraction: 0.4)
                            .padding(40)
                    }
                    .padding(.all, 20)
                    .padding(.bottom, 200)
                }
        }
        .vAlign(.top)
        .background(bgColor.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
        .customToolBar(
            dismissAction: {
                settings.isTabBarHidden = false
                presentationMode.wrappedValue.dismiss()
            },
            mainAction: {
                
            })
        .onAppear {
            settings.isTabBarHidden = true
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    struct Container: View {
        let settings = AppSettings()
        
        var body: some View {
            NavigationView {
                StatisticsView()
                    .environmentObject(settings)
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}

private extension View {
    func customToolBar(
        dismissAction: @escaping (() -> ()),
        mainAction: @escaping (() -> ())
    ) -> some View {
        return self.toolbar {
            ToolbarItem(placement: .principal) {
                Text("7-14 September 2023")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color("Blue"))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    mainAction()
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
