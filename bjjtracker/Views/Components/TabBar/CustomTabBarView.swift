//
//  CustomTabBarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case dashboard = "Dashboard"
    case calendar = "Calendar"
    case statistics = "Statistics"
    case profile = "Profile"
    
    var image: Image {
        switch self {
        case .dashboard:
            return Image("dashboard")
        case .profile:
            return Image("profile")
        case .statistics:
            return Image("stats")
        case .calendar:
            return Image("calendar")
        }
    }
}

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab
    
    @Namespace var namespace
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        selectedTab = tab
                    }
                }, label: {
                    if selectedTab == tab {
                        HStack {
                            tab.image
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("Purple"))
                            Text(tab.rawValue.localizedString)
                                .foregroundColor(Color("Purple"))
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .matchedGeometryEffect(id: "title", in: namespace)
                            
                        }
                        .padding(.all, 10)
                        .background(
                            Rectangle()
                                .fill(Color("PurpleBG"))
                                .cornerRadius(5)
                                .matchedGeometryEffect(id: "bg", in: namespace)
                        )
                    } else {
                        tab.image
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("Purple"))
                            .padding(.all, 20)
                    }
                })
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 30)
        .padding(.top, 10)
        .background(
            Rectangle()
                .fill(.white)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 2,
                    y: -1
                )
        )
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selected: Tab = .calendar
        
        CustomTabBarView(selectedTab: $selected)
    }
}
