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
                    .shadow(color: .black.opacity(0.11), radius: 4, x: 1, y: 2)
                Group {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(activity.status.color))
                            .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                            .shadow(color: .black.opacity(0.11), radius: 4, x: 1, y: 2)
                            .frame(width: 67)
                        VStack(alignment: .center, spacing: 6) {
                            Text("\(itemFormatter.string(from: activity.startDate))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("\(itemFormatter.string(from:activity.startDate + TimeInterval(activity.duration)))")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .fontWeight(.regular)
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                Group {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(activity.style.rawValue)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Text("\(activity.location ?? "")")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                        Text("\(activity.notes)")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                    }
                }.offset(x: -60)
                Group {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(activity.status.color))
                            .cornerRadius(5)
                            .shadow(color: .black.opacity(0.11), radius: 4, x: 1, y: 2)
                            .frame(width: 76, height: 23)
                        Text("\(activity.status.rawValue)".uppercased())
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }.padding(.all, 10)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }.frame(height: 103)
            .padding(.horizontal, 20)
    }
    
    private let itemFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
}

struct ActivityPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityPanelView(activity: Activity(type: .session, style: .noGi, duration: 60 * 60, startDate: Date()))
    }
}
