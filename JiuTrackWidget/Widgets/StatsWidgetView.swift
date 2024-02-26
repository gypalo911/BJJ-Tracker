//
//  StatsWidgetView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.02.2024.
//

import SwiftUI

struct StatsWidgetView: View {
    let sessions: [Session]
    let techniques: [TechniqueModel]
    
    var totalSessions: Int {
        sessions.count
    }
    
    var avgSessionTime: Double {
        let durations = sessions
            .filter { $0.duration > 0 }
            .map {
                Int($0.duration)
            }
        if durations.count == 0 {
            return 0
        }
        return Double(durations.reduce(0, +) / durations.count)
    }
    
    var avgCaloriesPerSession: Int {
        Int(avgSessionTime / 60 * 600)
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader { geometry in
                    let size = geometry.frame(in: .global).size
                    ZStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("All Time Stats")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Sessions")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("DefaultPurple"))
                                    Text("\(sessions.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .frame(width: size.width, height: 0.5)
                                    Text("Avg session time")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("DefaultPurple"))
                                    Text("\(avgSessionTime.stringFormatted())")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .frame(width: size.width, height: 0.5)
                                    Text("Avg Calories per session")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("DefaultPurple"))
                                    Text("\(avgCaloriesPerSession)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    Rectangle()
                                        .foregroundStyle(.gray)
                                        .frame(width: size.width, height: 0.5)
                                    Text("Techniques")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("DefaultPurple"))
                                    Text("\(techniques.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        
                        VStack {
                            Image("TransparentLogoSmall")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                            Spacer()
                        }
                        .hAlign(.trailing)
                    }
                }
            }
            .padding(20)
            .background(LinearGradient(gradient: Gradient(colors: [Color("LinearBG1"), Color("LinearBG2")]), startPoint: .top, endPoint: .bottom))
        }
}

#Preview {
    VStack {
        StatsWidgetView(sessions: Array(PersistanceManager.preview.fetchSessions().sorted(by: { $0.startDateString > $1.startDateString })), techniques: PersistanceManager.preview.fetchAllTechniques())
            .cornerRadius(25)
            .padding(20)
        SessionsListWidget(sessions: Array(PersistanceManager.preview.fetchSessions().sorted(by: { $0.startDateString > $1.startDateString })))
            .cornerRadius(25)
            .padding(20)
        LiveActivityView(session: PersistanceManager.preview.fetchSessions().first(where: { ($0.startDate?.timeIntervalSince(Date()))! < 50 })!)
            .cornerRadius(25)
            .padding(20)
    }
}
