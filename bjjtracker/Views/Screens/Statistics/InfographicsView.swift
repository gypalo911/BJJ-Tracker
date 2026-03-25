//
//  InfographicsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.04.2023.
//

import SwiftUI

struct InfographicsView: View {
    enum Localisation {
        static let classes = "Classes"
        static let competitions = "Competitions"
        static let seminars = "Seminars"
    }

    let strokeColor: Color
    let statsInfo: [ActivityType: Int]
    
    var body: some View {
        ZStack(alignment: .center) {
            ZStack {
                Circle()
                    .fill(DesignSystem.shared.colors.green)
                    .frame(width: 130, height: 130)
                VStack {
                    Text(verbatim: "\(statsInfo[.training] ?? 0)")
                        .font(token: DesignSystem.shared.fonts.title2, weight: .bold)
                    Text(Localisation.classes.localizedString)
                        .font(token: DesignSystem.shared.fonts.footnote, weight: .medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: -100, y: 50)
            .zIndex(0)
            ZStack {
                Circle()
                    .fill(DesignSystem.shared.colors.competition)
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 128, height: 128)
                VStack {
                    Text(verbatim: "\(statsInfo[.competition] ?? 0)")
                        .font(token: DesignSystem.shared.fonts.body, weight: .bold)
                    Text(Localisation.competitions.localizedString)
                        .font(token: DesignSystem.shared.fonts.caption, weight: .medium)
                }
                .foregroundColor(.white)
            }
            .offset(x: 0, y: 0)
            .zIndex(2)
            ZStack {
                Circle()
                    .fill(DesignSystem.shared.colors.seminar)
                    .frame(width: 95, height: 95)
                Circle()
                    .stroke(lineWidth: 8)
                    .fill(strokeColor)
                    .frame(width: 103, height: 103)
                VStack {
                    Text(verbatim: "\(statsInfo[.seminar] ?? 0)")
                        .font(token: DesignSystem.shared.fonts.body, weight: .bold)
                    Text(Localisation.seminars.localizedString)
                        .font(token: DesignSystem.shared.fonts.caption, weight: .medium)
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
            strokeColor: DesignSystem.shared.colors.generalBackground,
            statsInfo: [.training: 12, .competition: 0, .seminar: 0]
        ).padding(.bottom, 70)
    }
}
