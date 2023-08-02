//
//  PromotionsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 02.08.2023.
//

import SwiftUI

struct PromotionsView: View {
    var body: some View {
        VStack {
//            HStack {
//                Text("Progress")
//                    .font(.system(size: 18))
//                    .fontWeight(.semibold)
//                Spacer()
//            }
//            .padding([.leading, .top, .trailing], 15)
//            
//            VStack {
//                ForEach(Belt.belts(for: gradingSystem).filter { $0 != .none }, id: \.self) { belt in
//                    BeltProgressCell(
//                        belt: belt,
//                        isLocked: isLocked(belt: belt, lastPromotion: lastPromotion),
//                        promotionModels: promotionModels
//                    )
//                }
//            }
//            .padding(.horizontal, 5)
//            .padding(.bottom, 15)
        }
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(.white)
                .cornerRadius(10)
                .defaultShadow()
        )
    }
}

struct PromotionsView_Previews: PreviewProvider {
    static var previews: some View {
        PromotionsView()
    }
}
