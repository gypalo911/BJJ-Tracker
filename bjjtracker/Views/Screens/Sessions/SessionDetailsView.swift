//
//  SessionDetailsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI

struct SessionDetailsView: View {
    @State var activity: Activity
    @State var isPresentedEditing: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var navTitle = ""
    
    let linearGradient: LinearGradient
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
        linearGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: activity.type.color.opacity(0.8), location: 0.4),
                .init(color: activity.type.color.opacity(0.35), location: 0.8),
                .init(color: activity.type.color.opacity(0.28), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(activity.type.color.opacity(0.8))
        UINavigationBar.appearance().standardAppearance = appearance
        
        navTitle = "\(activity.style.rawValue) \(activity.type.rawValue)"
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    ZStack {
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
                                    Text("\(activity.startDate.toString("dd MMMM YYYY"))")
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
                                        Text("\(activity.startDate.toString("hh:mm"))")
                                            .font(.system(size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        let duration = activity.duration.minutesToDuration()
                                        if activity.duration != 0 {
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
                                    Text("\(activity.location == "" ? "--" : activity.location)")
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
                                Text(activity.notes)
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
                        appearance.backgroundColor = UIColor(activity.type.color.opacity(0.8))
                        UINavigationBar.appearance().standardAppearance = appearance
                    }) {
                        NewSessionView(presenter: NewSessionPresenter(activity: activity, isEditing: true))
                    }
                }
            }
        }
    }
}

struct SessionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let activity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "asdsad", notes: "asdasdas")
        
        SessionDetailsView(activity: activity)
    }
}
