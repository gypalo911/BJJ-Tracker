//
//  TestDashboardView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 20.08.2023.
//

import SwiftUI

struct TestDashboardView: View {
    @State private var headerHeight: CGFloat = 660
    @State private var offsetY: CGFloat = .zero
    @State private var shouldCollapseHeader: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            let safeArea = proxy.safeAreaInsets.top
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HeaderView(safeArea)
                        .offset(y: -offsetY)
                        .zIndex(1000)
                    
                    ForEach(1..<3) { item in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.blue)
                            .frame(height: 200)
                            .padding(10)
                    }
                }
                .offset(coordinateSpace: .named("scroll")) { offset in
                    offsetY = offset
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if offset <= -100 {
                            shouldCollapseHeader = true
                        }
                        if offset >= 100 {
                            shouldCollapseHeader = false
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .edgesIgnoringSafeArea(.top)
        }
    }
    
    @ViewBuilder
    func HeaderView(_ safeAreaTop: CGFloat) -> some View {
        VStack {
            Text("Title text")
                .font(.title)
                .foregroundColor(.white)
                .opacity(shouldCollapseHeader ? 0 : 1)
            HStack(spacing: shouldCollapseHeader ? 60 : 20) {
                Image("archive")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Image("dashboard")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Image("calendar")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Image("profile")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            }
            .hAlign(.center)
            .background(
                Rectangle()
                    .fill(.yellow)
            )
            .offset(y: shouldCollapseHeader ? 20 : 60)
        }
//        .frame(height: shouldCollapseHeader ? 150 : 300)
        .padding([.bottom, .horizontal], 20)
        .padding(.top, safeAreaTop + 10)
        .edgesIgnoringSafeArea(.top)
        .padding(.bottom, 50)
        .background(
            Rectangle()
                .fill(.red)
//                .padding(.bottom, shouldCollapseHeader ? 10 : 0)
        )
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = .zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offset(
        coordinateSpace: CoordinateSpace,
        completion: @escaping (CGFloat) -> ()
    ) -> some View {
        self
            .overlay(
                GeometryReader { proxy in
                    let minY = proxy.frame(in: coordinateSpace).minY
                    Color.clear
                        .preference(key: OffsetPreferenceKey.self, value: minY)
                        .onPreferenceChange(OffsetPreferenceKey.self) { value in
                            completion(value)
                        }
                }
            )
    }
}

struct TestDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        TestDashboardView()
    }
}
