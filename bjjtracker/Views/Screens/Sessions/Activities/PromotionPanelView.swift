//
//  PromotionPanelView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import SwiftUI

struct PromotionPanelView: View {
    @ObservedObject var promotion: Promotion
    
    var body: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .defaultShadow()
                
                HStack {
                    CircularBeltView(primaryColor: promotion.belt.color.0, secondaryColor: promotion.belt.color.1)
                    HStack(spacing: 4) {
                        Text("You’ve reached")
                            .font(.footnote)
                        Text(promotion.stripes > 0 ? "%@ belt %@ stripes!".localized(with: ["\(promotion.belt.title)", "\(promotion.stripes)"]) : "%@ belt!".localized(with: ["\(promotion.belt.title)"]))
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                }
                .hAlign(.leading)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }
        }
        .frame(height: 58)
        .padding(.horizontal, 20)
    }
}

struct PromotionPanelView_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(
            sortDescriptors: [], animation: .easeInOut
        ) var promotionsList: FetchedResults<PromotionModel>

        var body: some View {
            let promotion: Promotion = Promotion.from(promotionsList.map { $0 }.first!)
            PromotionPanelView(promotion: promotion)
        }
    }

    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}

