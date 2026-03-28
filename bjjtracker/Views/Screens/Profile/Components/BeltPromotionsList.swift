//
//  BeltPromotionsList.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.05.2023.
//

import SwiftUI

struct BeltPromotionsList: View {
    @EnvironmentObject var persistanceManager: PersistanceManager
    
    var promotionModels: [FetchedResults<PromotionModelEntity>.Element]
    
    var promotions: [Promotion] {
        promotionModels.map {
            Promotion.from($0)
        }.sorted(by: {
            $0.stripes < $1.stripes
        })
    }
    
    @Environment(\.managedObjectContext) var managedObjContext
    
    var body: some View {
        List {
            ForEach(promotions.prefix(5), id: \.id) { promotion in
                BeltPromotionsListCell(stripes: promotion.stripes, date: promotion.date)
                    .padding(5)
            }.onDelete { offsets in
                withAnimation(.easeInOut(duration: 0.3)) {
                    for index in offsets {
                        let model = promotionModels[index]
                        persistanceManager.delete(model: model, context: managedObjContext)
                    }
                }
            }
            .background(DesignSystem.shared.colors.listBackground)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(.zero))
        }
        .listStyle(.inset)
        .scrollDisabled(true)
        .frame(minHeight: 50 * CGFloat(promotions.prefix(5).count))
    }
}

struct BeltPromotionsList_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut) var promotionModels: FetchedResults<PromotionModelEntity>
        
        var body: some View {
            BeltPromotionsList(promotionModels: promotionModels.map { $0 })
        }
    }
    
    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
