//
//  BeltsListView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

struct BeltsListView: View {
    @ObservedObject var promotion: Promotion

    var body: some View {
        ScrollViewReader { scrollValue in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if promotion.gradingSystem == .adult {
                        ForEach(AdultBelts.allCases.filter { $0 != .none }, id: \.self) { belt in
                            let isSelected = promotion.adultBelt == belt
                            Button(action: {
                                promotion.adultBelt = belt
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollValue.scrollTo(belt)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(belt.color.0)
                                        .frame(width: 100, height: 50)
                                        .overlay(isSelected ? RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3)
                                                 : RoundedRectangle(cornerRadius: 10).stroke(Color("LightGray"), lineWidth: 1))
                                        .shadow(color: isSelected ? Color("Blue") : .clear, radius: 2, x: 0, y: 1)
                                    Rectangle()
                                        .fill(belt.color.1 ?? .clear)
                                        .frame(height: 10)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    } else {
                        ForEach(JuniorBelts.allCases.filter { $0 != .none }, id: \.self) { belt in
                            let isSelected = promotion.juniorBelt == belt
                            Button(action: {
                                promotion.juniorBelt = belt
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollValue.scrollTo(belt)
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(belt.color.0)
                                        .frame(width: 100, height: 50)
                                        .overlay(isSelected ? RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 3) : RoundedRectangle(cornerRadius: 10).stroke(Color("LightGray"), lineWidth: 1))
                                        .shadow(color: isSelected ? Color("Blue") : .clear, radius: 2, x: 0, y: 1)
                                    Rectangle()
                                        .fill(belt.color.1 ?? .clear)
                                        .frame(height: 10)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct BeltsListViewProvider_Previews: PreviewProvider {
    struct BeltsView: View {
        @StateObject var promotion: Promotion = .init(gradingSystem: .junior, stripes: 0, date: Date(), location: "", notes: "")

        var body: some View {
            BeltsListView(promotion: promotion)
        }
        
    }
    static var previews: some View {
        BeltsView()
    }
}
