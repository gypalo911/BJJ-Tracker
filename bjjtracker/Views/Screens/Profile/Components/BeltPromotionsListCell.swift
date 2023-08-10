//
//  BeltPromotionsListCell.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.05.2023.
//

import SwiftUI

struct BeltPromotionsListCell: View {
    let stripes: Int
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 10)
                Text("Stripes: %@".localized(with: ["\(stripes)"]))
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            Text(date.toString("dd MMMM yyyy"))
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
                .padding(.leading, 20)
        }
        .padding(.horizontal, 20)
        .hAlign(.leading)
    }
}

struct BeltPromotionsListCell_Previews: PreviewProvider {
    static var previews: some View {
        BeltPromotionsListCell(stripes: 1, date: Date())
    }
}
