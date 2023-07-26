//
//  ActivityPanelView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import SwiftUI

struct ActivityPanelView: View {
    @ObservedObject var session: Session
    
    let namespace: Namespace.ID
    
    var sessionId: String {
        session.id?.uuidString ?? ""
    }
    
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
                            .foregroundColor(session.activityType.color)
                            .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                            .defaultShadow()
                            .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace)
                            .frame(width: 67)
                        VStack(alignment: .center, spacing: 6) {
                            Text("\((session.startDate ?? Date()).toString("HH:mm"))")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("\(((session.startDate ?? Date()) + TimeInterval(session.duration * 60)).toString("HH:mm"))")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .fontWeight(.regular)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(session.activityType.rawValue.localizedString)")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Text("\(session.activityStyle.rawValue.localizedString) • \(session.location ?? "")")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                        Text(LocalizedStringKey(session.notes ?? ""))
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.6))
                            .fontWeight(.regular)
                            .textSelection(.enabled)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }.padding(.horizontal, 10)
                }.hAlign(.leading)
                Group {
                    ZStack {
                        Rectangle()
                            .foregroundColor(session.status.color)
                            .cornerRadius(5)
                            .defaultShadow()
                            .frame(width: 76, height: 23)
                        Text("\(session.status.rawValue.localizedString)".uppercased())
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding(.all, 10)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .frame(height: 103)
        .padding(.horizontal, 20)
    }
}

struct ActivityPanelView_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        
        @Namespace var namespace

        var body: some View {
            let session: Session = sessionsList.map { $0 }.first!
            ActivityPanelView(session: session, namespace: namespace)
        }
    }

    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
