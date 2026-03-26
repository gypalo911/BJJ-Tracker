//
//  TabBarViewV1.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 06.04.2023.
//

import SwiftUI

struct TabBarViewV1: View {
    @Binding var selectedTab: CustomTab
    
    @Namespace var namespace
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(CustomTab.allCases, id: \.rawValue) { tab in
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
                                .foregroundColor(DesignSystem.shared.colors.purple)
                            Text(tab.rawValue.localizedString)
                                .foregroundColor(DesignSystem.shared.colors.purple)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .matchedGeometryEffect(id: "title", in: namespace)
                            
                        }
                        .padding(.all, 10)
                        .background(
                            Rectangle()
                                .fill(DesignSystem.shared.colors.purpleBackground)
                                .cornerRadius(5)
                                .matchedGeometryEffect(id: "bg", in: namespace)
                        )
                    } else {
                        tab.image
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(DesignSystem.shared.colors.purple)
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
    struct Container: View {
        @State var selected: CustomTab = .calendar
        
        var body: some View {
            TabBarViewV1(selectedTab: $selected)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
