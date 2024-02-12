//
//  BeltsListView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

struct BeltsListView: View {
    @ObservedObject var promotion: Promotion
    
    var belts: [Belt] {
        Belt.belts(for: promotion.gradingSystem).filter { $0 != .none }
    }
    
    var body: some View {
        ScrollViewReader { scrollValue in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(belts.indices, id: \.self) { i in
                        let belt = belts[i]
                        let isSelected = promotion.belt == belt
                        CircularBeltView(
                            primaryColor: belt.color.0,
                            secondaryColor: belt.color.1,
                            isSelected: isSelected
                        ).onTapGesture {
                            promotion.belt = belt
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scrollValue.scrollTo(belt)
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
        @StateObject var promotion: Promotion = .init(belt: .blue, stripes: 2, date: Date(), location: "", notes: "")
        
        var body: some View {
            BeltsListView(promotion: promotion)
        }
        
    }
    static var previews: some View {
        BeltsView()
    }
}
