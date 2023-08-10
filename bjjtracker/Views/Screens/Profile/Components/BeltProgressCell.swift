//
//  BeltProgressCell.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.05.2023.
//

import SwiftUI

struct BeltProgressCell: View {
    @State private var showPromotionsList: Bool = false
    
    private var belt: Belt
    
    private var showListBG: Bool {
        showPromotionsList && !promotionModels.isEmpty
    }
    var promotionModels: [FetchedResults<PromotionModel>.Element]
    
    private let isLocked: Bool
    
    init(belt: Belt, isLocked: Bool, promotionModels: [PromotionModel]) {
        self.belt = belt
        self.isLocked = isLocked
        self.promotionModels = promotionModels.filter {
            $0.belt == belt.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            CircularBeltView(
                                primaryColor: belt.color.0,
                                secondaryColor: belt.color.1
                            )
                            if isLocked {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 36)
                                Image("lock")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                        }
                        
                        Text("%@ belt".localized(with: ["\(belt.title)"]))
                    }
                    Spacer()
                    if !promotionModels.isEmpty {
                        Image("info")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if !promotionModels.isEmpty {
                            showPromotionsList.toggle()
                        }
                    }
                }
                if belt != .black {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
                if showPromotionsList {
                    BeltPromotionsList(promotionModels: promotionModels)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(showListBG ? Color("listBG") : Color.white)
        )
    }
}

struct BeltProgressCell_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut) var promotionModels: FetchedResults<PromotionModel>
        
        var body: some View {
            BeltProgressCell(
                belt: .blue,
                isLocked: false,
                promotionModels: promotionModels.map { $0 }
            )
        }
    }
    
    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
