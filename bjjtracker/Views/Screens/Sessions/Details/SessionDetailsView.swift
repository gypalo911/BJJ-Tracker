//
//  SessionDetailsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct SessionDetailsView: View {
    @ObservedObject var session: Session
    @State var isPresentedEditing: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var dismissCallback: (() -> Void)?
    
    init(session: Session, dismissCallback: (() -> Void)? = nil) {
        self.session = session
        self.dismissCallback = dismissCallback
    }
    
    var body: some View {
        let navTitle = "\(self.session.activityStyle.rawValue) \(self.session.activityType.rawValue)"
        let linearGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: self.session.activityType.color.opacity(0.8), location: 0.4),
                .init(color: self.session.activityType.color.opacity(0.35), location: 0.8),
                .init(color: self.session.activityType.color.opacity(0.28), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    ZStack {
                        Group {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(session.status.color)
                                    .cornerRadius(5)
                                    .defaultShadow()
                                    .frame(width: 76, height: 23)
                                Text("\(session.status.rawValue)".uppercased())
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }.padding(.all, 30)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        VStack(alignment: .leading, spacing: 20) {
                            Text(navTitle)
                                .font(.system(size: 28).bold())
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            VStack(alignment: .leading, spacing: 20) {
                                HStack(spacing: 10) {
                                    Image("calendar")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                    Text("\(session.startDate!.toString("dd MMMM YYYY"))")
                                        .font(.system(size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                HStack(spacing: 10) {
                                    Image("watch")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                    HStack {
                                        Text("\(session.startDate!.toString("hh:mm"))")
                                            .font(.system(size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        let duration = Int(session.duration).minutesToDuration()
                                        if session.duration != 0 {
                                            Text("(\(duration))")
                                                .font(.system(size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                HStack(spacing: 10) {
                                    Image("location")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                    Text("\(session.location ?? "--")")
                                        .font(.system(size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }.padding(10)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Notes")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("Gray"))
                                Text(session.notes ?? "")
                                    .font(.system(size: 18))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                        }
                        .hAlign(.leading)
                        .vAlign(.top)
                        .padding(20)
                        .onDisappear {
                            let appearance = UINavigationBarAppearance()
                            appearance.backgroundColor = .clear
                            UINavigationBar.appearance().standardAppearance = appearance
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    dismissCallback?()
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image("back")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isPresentedEditing = true
                                    let appearance = UINavigationBarAppearance()
                                    appearance.backgroundColor = .clear
                                    UINavigationBar.appearance().standardAppearance = appearance
                                } label: {
                                    Text("Edit")
                                        .fixedSize()
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .background {
                        Rectangle()
                            .fill(linearGradient)
                            .ignoresSafeArea()
                            .cornerRadius(30, corners: [.bottomLeft])
                            .frame(height: 480)
                            .position(CGPoint(x: geometry.size.width/2, y: 0))
                            .defaultShadow()
                    }
                    .sheet(isPresented: $isPresentedEditing, onDismiss: {
                        let appearance = UINavigationBarAppearance()
                        appearance.backgroundColor = UIColor(session.activityType.color.opacity(0.8))
                        UINavigationBar.appearance().standardAppearance = appearance
                    }) {
                        EditSessionView(
                            session: session,
                            activity: Activity.from(session: session)!,
                            onDismiss: { editedActivity in
//                                session = editedActivity
                            }
                        )
                    }
                }
                .onAppear {
                    changeNavBar()
                }
            }
        }
    }
    
    func changeNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(self.session.activityType.color.opacity(0.8))
        UINavigationBar.appearance().standardAppearance = appearance
    }
}

//struct SessionDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var activity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "asdsad", notes: "asdasdas")
//
//        SessionDetailsView(activity: activity)
//    }
//}
