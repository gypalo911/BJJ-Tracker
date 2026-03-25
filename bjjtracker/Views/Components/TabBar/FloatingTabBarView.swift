//
//  FloatingTabBarView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 22.07.2023.
//

import SwiftUI

struct FloatingTabBarView: View {
    @Binding var selectedTab: Tab
    
    var onCreate: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .center, spacing: 30) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, blendDuration: 6)) {
                        selectedTab = tab
                    }
                }, label: {
                    (selectedTab == tab ? tab.selectedImage : tab.image)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(selectedTab == tab ? DesignSystem.shared.colors.purple : DesignSystem.shared.colors.lightGray)
                })
                .buttonStyle(BouncyButton())
                if tab == .calendar {
                    Button(action: {
                        onCreate?()
                    }, label: {
                        ZStack {
                            Circle()
                                .foregroundColor(DesignSystem.shared.colors.blue)
                            Image("plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.white)
                        }
                        .frame(width: 52, height: 52)
                    })
                    .buttonStyle(BouncyButton())
                }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 30)
        .background(
            Rectangle()
                .fill(.white)
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 2,
                    y: -1
                )
                .cornerRadius(30, corners: .allCorners)
                .shadow(color: .black.opacity(0.15), radius: 2.5, x: 0, y: 1)
        )
    }
}

struct FloatingTabBarView_Previews: PreviewProvider {
    struct Container: View {
        @State var selected: Tab = .dashboard
        var body: some View {
            FloatingTabBarView(selectedTab: $selected)
                .vAlign(.bottom)
                .padding(.bottom, 30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
