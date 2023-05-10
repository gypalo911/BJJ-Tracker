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
                            CircularBeltView(
                                primaryColor: belt.color.0,
                                secondaryColor: belt.color.1,
                                isSelected: isSelected
                            ).onTapGesture {
                                promotion.adultBelt = belt
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollValue.scrollTo(belt)
                                }
                            }
                        }
                    } else {
                        ForEach(JuniorBelts.allCases.filter { $0 != .none }, id: \.self) { belt in
                            let isSelected = promotion.juniorBelt == belt
                            CircularBeltView(
                                primaryColor: belt.color.0,
                                secondaryColor: belt.color.1,
                                isSelected: isSelected
                            ).onTapGesture {
                                promotion.juniorBelt = belt
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    scrollValue.scrollTo(belt)
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
