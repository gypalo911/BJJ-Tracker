//
//  StatsPanelsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 08.04.2023.
//

import SwiftUI

struct StatsView: View {
    let text: String
    let value: String
    var tendecyGrows: Bool? = nil
    var tendecyValue: String? = nil
    
    let zeroTendencies: [String] = ["0", "0min", "0хв"]
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.footnote)
                        .fontWeight(.semibold)
                    Text(value)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            if let tendecyValue = tendecyValue, !zeroTendencies.contains(tendecyValue)
            {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack(spacing: 0) {
                            if let tendecyGrows = tendecyGrows {
                                Image(tendecyGrows ? "arrowUp" : "arrowDown")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(tendecyGrows ? Color("darkenGreen") : Color("darkenRed"))
                                Text(tendecyValue)
                                    .fixedSize()
                                    .font(.caption2)
                                    .foregroundColor(tendecyGrows ? Color("darkenGreen") : Color("darkenRed"))
                            } else {
                                Text(tendecyValue)
                                    .fixedSize()
                                    .font(.caption)
                                    .foregroundColor(Color("darkenGreen"))
                            }
                        }
                    }
                    .padding(.all, 5)
                    .background(
                        Rectangle()
                            .fill(tendecyGrows != nil ? (tendecyGrows! ? Color("lightGreen") : Color("lightRed")) : Color("lightGreen"))
                            .cornerRadius(10)
                    )
                    .vAlign(.topTrailing)
                }
            }
        }
        .frame(height: 60)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(.white)
                .cornerRadius(10)
                .defaultShadow()
        )
    }
}

struct StatsViewProvider_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 10) {
            StatsView(text: "Sessions", value: "3333", tendecyGrows: true, tendecyValue: "0")
            StatsView(text: "Total time", value: "25h 25m", tendecyGrows: false, tendecyValue: "0min")
        }.padding(20)
    }
}
