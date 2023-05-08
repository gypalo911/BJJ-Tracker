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
                    .frame(width: 130)
                VStack {
                    Text("\(statsInfo[.training] ?? 0)")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    Text("classes")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: -100, y: 50)
            .zIndex(0)
            ZStack {
                Circle()
                    .fill(Color("Competition"))
                    .frame(width: 120)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 128)
                VStack {
                    Text("\(statsInfo[.competition] ?? 0)")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Text("Competitions")
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: 0, y: 0)
            .zIndex(2)
            ZStack {
                Circle()
                    .fill(Color("Seminar"))
                    .frame(width: 95)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 103)
                VStack {
                    Text("\(statsInfo[.seminar] ?? 0)")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Text("Seminars")
                        .font(.system(size: 12))
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
            statsInfo: [.training: 12, .competition: 5, .seminar: 3]
        ).padding(.bottom, 70)
    }
}
