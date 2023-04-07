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
    let tendecyGrows: Bool?
    let tendecyValue: String
    
    var body: some View {
        ZStack {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.6))
                        .fontWeight(.semibold)
                    Text(value)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                }
                Spacer()
            }
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
                                .font(.system(size: 12))
                                .foregroundColor(tendecyGrows ? Color("darkenGreen") : Color("darkenRed"))
                        } else {
                            Text(tendecyValue)
                                .fixedSize()
                                .font(.system(size: 12))
                                .foregroundColor(Color("darkenGreen"))
                        }
                    }
                }
                .padding(.all, 5)
                .frame(maxWidth: 76)
                .background(
                    Rectangle()
                        .fill(tendecyGrows != nil ? (tendecyGrows! ? Color("lightGreen") : Color("lightRed")) : Color("lightGreen"))
                        .cornerRadius(10)
                )
                .vAlign(.bottomTrailing)
            }
        }
        .frame(height: 60)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(.white)
                .cornerRadius(10)
        )
    }
}

struct StatsViewProvider_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 10) {
            StatsView(text: "Sessions", value: "3", tendecyGrows: true, tendecyValue: "2")
            StatsView(text: "Total time", value: "2568h", tendecyGrows: false, tendecyValue: "4h 20m")
        }.padding(20).background(Rectangle().fill(.blue))
    }
}
