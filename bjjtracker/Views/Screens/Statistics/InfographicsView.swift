//
//  InfographicsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.04.2023.
//

import SwiftUI

struct InfographicsView: View {
    let strokeColor: Color
    let statsInfo: [ActivityType: Int]
    
    var body: some View {
        ZStack(alignment: .center) {
            ZStack {
                Circle()
                    .fill(Color("Green"))
                    .frame(width: 130, height: 130)
                VStack {
                    Text("\(statsInfo[.training] ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Classes")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: -100, y: 50)
            .zIndex(0)
            ZStack {
                Circle()
                    .fill(Color("Competition"))
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 128, height: 128)
                VStack {
                    Text("\(statsInfo[.competition] ?? 0)")
                        .font(.body)
                        .fontWeight(.bold)
                    Text("Competitions")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: 0, y: 0)
            .zIndex(2)
            ZStack {
                Circle()
                    .fill(Color("Seminar"))
                    .frame(width: 95, height: 95)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 103, height: 103)
                VStack {
                    Text("\(statsInfo[.seminar] ?? 0)")
                        .font(.body)
                        .fontWeight(.bold)
                    Text("Seminars")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: 85, y: 50)
            .zIndex(1)
        }
    }
}

struct InfographicsView_Previews: PreviewProvider {
    static var previews: some View {
        InfographicsView(
            strokeColor: Color("generalBG"),
            statsInfo: [.training: 12, .competition: 0, .seminar: 0]
        ).padding(.bottom, 70)
    }
}
