//
//  PromotionPanelView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import SwiftUI

struct PromotionPanelView: View {
    private enum Localisation {
        static var reached: String { "You’ve reached".localizedString }

        static func beltWithStripes(_ belt: String, stripes: String) -> String {
            "%@ belt %@ stripes!".localized(with: [belt, stripes])
        }

        static func belt(_ belt: String) -> String {
            "%@ belt!".localized(with: [belt])
        }
    }

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
                        Text(Localisation.reached)
                            .font(.footnote)
                        Text(
                            promotion.stripes > 0
                            ? Localisation.beltWithStripes("\(promotion.belt.title)", stripes: "\(promotion.stripes)")
                            : Localisation.belt("\(promotion.belt.title)")
                        )
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
