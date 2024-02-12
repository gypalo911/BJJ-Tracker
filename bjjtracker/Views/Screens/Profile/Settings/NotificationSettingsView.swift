//
//  NotificationSettingsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 04.08.2023.
//

import SwiftUI

protocol StringComparable {
    var stringValue: String { get set }
}

class NotificationPrefferences: Identifiable, ObservableObject {
    var timeLimits: [Int] = [30, 45, 60, 120]
    
    @Published var sessionRemindersOn: Bool = true
    @Published var achivementRemindersOn: Bool = true
    @Published var statisticsNotificationsOn: Bool = true
    
    @Published var selectedTimeLimit: Int = 60
}

extension Int: StringComparable {
    var stringValue: String {
        get {
            return String(self)
        }
        set {}
    }
    
    
}

struct NotificationSettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var appLanguage: AppSettings.AppLanguage = .english
    
    @ObservedObject var notificationPrefferences = NotificationPrefferences()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 40, height: 40)
                            .background(Color(red: 0.96, green: 0.97, blue: 1))
                            .cornerRadius(10)
                        Image("notification")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }
                    Text("Notifications".localizedString)
                        .font(.body)
                        .fontWeight(.bold)
                }
                .hAlign(.leading)
                if !NotificationManager.shared.isAuthorized {
                    VStack(alignment: .center, spacing: 15) {
                        Text("Allow push notifications")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text("Be notified about nearest events and\nachivements. You can change it anytime.")
                            .font(.footnote)
                            .fontWeight(.regular)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            if NotificationManager.shared.authrorizationStatus == .denied {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                            } else {
                                NotificationManager.shared.requestAuthorization { _ in }
                            }
                        }, label: {
                            Text("Allow notifications")
                                .font(.callout)
                        })
                    }
                    .padding(.vertical, 40)
                } else {
                    VStack {
                        VStack {
                            Toggle(isOn: $notificationPrefferences.sessionRemindersOn, label: {
                                Text("Session reminders")
                                    .font(.footnote)
                                    .fontWeight(.regular)
                            })
                            VStack {
                                HStack {
                                    Image("notification")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.black)
                                        .frame(width: 15, height: 15)
                                    Text("Notifications".localizedString)
                                        .font(.caption)
                                        .fontWeight(.regular)
                                }
                                .hAlign(.leading)
                                
                                OptionSelector(g: geometry, valuesList: notificationPrefferences.timeLimits, selectedValue: notificationPrefferences.selectedTimeLimit)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("LightLightGray"))
                            )
                            .frame(maxWidth: .infinity)
                        }
                        Toggle(isOn: $notificationPrefferences.achivementRemindersOn, label: {
                            Text("Achivement notifications")
                                .font(.footnote)
                                .fontWeight(.regular)
                        })
                        Toggle(isOn: $notificationPrefferences.statisticsNotificationsOn, label: {
                            Text("Statistics")
                                .font(.footnote)
                                .fontWeight(.regular)
                        })
                    }
                }
            }
            .padding(20)
            .vAlign(.top)
            .onAppear {
                
            }
            .onChange(of: NotificationManager.shared.authrorizationStatus) { status in
                
            }
        }
    }
}

struct OptionSelector: View {
    let g: GeometryProxy
    let valuesList: [StringComparable]
    
    var valuesStrings: [String] {
        return valuesList.map { $0.stringValue }
    }
    
    @State var selectedValue: StringComparable
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(valuesStrings.indices, id: \.self) { i in
                    let type = valuesStrings[i]
                    RectangleOption(type: "\(type)min", selectedType: $selectedValue.stringValue, horizontalPadding: 15)
                        .alignmentGuide(.leading, computeValue: { d in
                            if (abs(width - d.width) > g.size.width)
                            {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if type == valuesList.last!.stringValue {
                                width = 0 //last item
                            } else {
                                width -= d.width
                            }
                            return result
                        })
                        .alignmentGuide(.top, computeValue: { d in
                            let result = height
                            if type == valuesList.last!.stringValue {
                                height = 0 // last item
                            }
                            return result
                        })
                }
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    struct Container: View {
        @State private var isShowingOverlay: Bool = true
        
        var body: some View {
            NavigationView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global).size
                    ZStack {
                        Image("LogoWithText")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: frame.width, height: frame.height)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isShowingOverlay = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(
                    isPresented: $isShowingOverlay) {
                        NotificationSettingsView()
                    }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
    }
}
