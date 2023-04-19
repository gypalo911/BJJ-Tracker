//
//  ActivityPanelView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct ActivityPanelView: View {
    let activity: Activity
    
    var body: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .defaultShadow()
                HStack(alignment: .center) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(activity.type.color)
                            .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                            .defaultShadow()
                            .frame(width: 67)
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(activity.startDate.toString("HH:mm"))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("\((activity.startDate + TimeInterval(activity.duration * 60)).toString("HH:mm"))")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .fontWeight(.regular)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(activity.type.rawValue)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Text("\(activity.style.rawValue) • \(activity.location )")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                        Text("\(activity.notes)")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }.padding(.horizontal, 10)
                }.hAlign(.leading)
                Group {
                    ZStack {
                        Rectangle()
                            .foregroundColor(activity.status.color)
                            .cornerRadius(5)
                            .defaultShadow()
                            .frame(width: 76, height: 23)
                        Text("\(activity.status.rawValue)".uppercased())
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }.padding(.all, 10)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(height: 103)
        .padding(.horizontal, 20)
    }
}

struct ActivityPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPanelView(activity: Activity(type: .session, style: .noGi, duration: 60, startDate: Date(), location: "Lustsk", notes: "On this training I learned something new"))
    }
}
