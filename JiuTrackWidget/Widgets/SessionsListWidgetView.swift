//
//  SessionsListWidget.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.02.2024.
//

import SwiftUI

struct SessionsListWidget: View {
    let sessions: [Session]
    
    var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                ZStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            VStack(alignment: .leading, spacing: 5) {
                                if sessions.count > 0 {
                                    ForEach(sessions.prefix(3).indices, id: \.self) { index in
                                        let session = sessions[index]
                                        HStack(alignment: .center, spacing: 10) {
                                            Rectangle()
                                                .foregroundStyle(session.activityType.color)
                                                .frame(width: 6, height: 20)
                                            Text("\((session.startDate ?? Date()).toString("HH:mm"))")
                                                .font(.headline)
                                                .fontWeight(.regular)
                                                .foregroundStyle(.white)
                                                .frame(width: 50)
                                            Text("\(session.activityType.rawValue.localizedString)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                            Text("\(session.activityStyle.rawValue.localizedString)")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color("GrayTextColor"))
                                        }
                                    }
                                } else {
                                    Text("No sessions")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .vAlign(.center)
                                }
                            }
                            .vAlign(.top)
                        }
                       Spacer()
                    }
                    
                    VStack {
                        Image("TransparentLogoSmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        Spacer()
//                        ZStack {
//                            Circle()
//                                .foregroundColor(Color("DefaultBlue"))
//                            Image("plus")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 14, height: 14)
//                                .foregroundColor(.white)
//                        }
//                        .frame(width: 35, height: 35)
                    }
                    .hAlign(.trailing)
                }
            }
            .padding(20)
            .background(LinearGradient(gradient: Gradient(colors: [Color("LinearBG1"), Color("LinearBG2")]), startPoint: .top, endPoint: .bottom))
        }
}

#Preview {
    SessionsListWidget(sessions: Array(PersistanceManager.preview.fetchSessions().sorted(by: { $0.startDateString > $1.startDateString })))
        .padding(.top, 200)
}
