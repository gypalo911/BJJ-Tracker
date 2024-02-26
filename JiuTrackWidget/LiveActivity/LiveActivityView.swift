//
//  LiveActivityView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.02.2024.
//

import SwiftUI
import WidgetKit

struct LiveActivityView: View {
//        let state: SessionAttributes.ContentState
    
    let session: Session
    
    var endTime: Date {
        (session.startDate ?? Date()) + TimeInterval(session.duration * 60)
    }
    
    var widthProportion: CGFloat {
        return Date().timeIntervalSince((session.startDate ?? Date())) / Double(session.duration)
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(session.activityType.rawValue.localizedString)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("\(session.activityStyle.rawValue.localizedString) • \(session.location ?? "")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack {
                        Image("TransparentLogoSmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                        Spacer()
                    }
                }
                HStack(alignment: .center, spacing: 10) {
                    Text("\((session.startDate ?? Date()).toString("HH:mm"))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    GeometryReader { reader in
                        let viewSize = reader.frame(in: .global).size
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 10)
                                .frame(maxWidth: viewSize.width)
                                .foregroundStyle(Color("DefaultBlue"))
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 10)
                                .frame(width: widthProportion * viewSize.width)
                                .foregroundStyle(.white)
                        }
                        .vAlign(.center)
                    }
                    Text("\(((session.startDate ?? Date()) + TimeInterval(session.duration * 60)).toString("HH:mm"))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background(LinearGradient(gradient: Gradient(colors: [Color("LinearBG1"), Color("LinearBG2")]), startPoint: .top, endPoint: .bottom))
        }
}

#Preview {
    LiveActivityView(session: PersistanceManager.preview.fetchSessions().first(where: { ($0.startDate?.timeIntervalSince(Date()))! < 50 })!)
        .padding(.top, 200)
}
