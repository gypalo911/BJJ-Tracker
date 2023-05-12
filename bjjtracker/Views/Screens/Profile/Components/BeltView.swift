//
//  BeltView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.05.2023.
//

import SwiftUI

struct BeltView: View {
    var beltWidth: CGFloat = 210
    var beltColor: (Color, Color?)
    var stripesCount: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(beltColor.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Gray"), lineWidth: 1)
                )
                .frame(width: beltWidth, height: 36)
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(beltColor.1 ?? .black)
                    .frame(width: 65, height: 36)
                HStack(spacing: 5) {
                    ForEach(0..<stripesCount, id: \.self) { stripe in
                        Rectangle()
                            .fill(.white)
                            .frame(width: 6)
                    }
                }
                .hAlign(.leading)
                .frame(width: 65, height: 34)
                .offset(x: 10, y: 0)
            }.offset(x: 20)
        }
    }
}

struct BeltView_Previews: PreviewProvider {
    static var previews: some View {
        BeltView(beltColor: (.blue, nil), stripesCount: 4)
    }
}
