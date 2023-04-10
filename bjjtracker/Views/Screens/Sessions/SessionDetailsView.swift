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
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        
        navTitle = "\(activity.startDate.toString("dd MMMM YYYY"))\n\(activity.startDate.toString("hh:mm")) \(activity.type.rawValue)"
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
                                .font(.title.bold())
                                .padding(.top, 10)
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text(activity.type.rawValue)
                                        .fontWeight(.regular)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 6)
                                        .background(
                                            ZStack(alignment: .center) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color("Blue"), lineWidth: 2)
                                                    .foregroundColor(.white)
                                            }
                                        )
                                    Text(activity.style.rawValue)
                                        .fontWeight(.regular)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 6)
                                        .background(
                                            ZStack(alignment: .center) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color("Blue"), lineWidth: 2)
                                                    .foregroundColor(.white)
                                            }
                                        )
                                }
                                HStack {
                                    TitleTextView(text: "Duration:")
                                    let hours = activity.duration.formatMinutes().0
                                    if hours != "0" {
                                        HStack(alignment: .bottom, spacing: 2) {
                                            Text("\(hours)")
                                                .font(.system(size: 20))
                                                .fontWeight(.regular)
                                                .foregroundColor(.black)
                                            Text("h")
                                                .fontWeight(.regular)
                                                .foregroundColor(.black)
                                        }
                                    }
                                    let minutes = activity.duration.formatMinutes().1
                                    HStack(alignment: .bottom, spacing: 2) {
                                        Text("\(minutes)")
                                            .font(.system(size: 20))
                                            .fontWeight(.regular)
                                            .foregroundColor(.black)
                                        Text("min")
                                            .fontWeight(.regular)
                                            .foregroundColor(.black)
                                    }
                                }
                                if activity.location != "" {
                                    HStack {
                                        TitleTextView(text: "Location:")
                                        Text("\(activity.location)")
                                    }
                                }
                                Text(activity.notes)
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                            }.padding(10)
                            
                            
                        }
                        .hAlign(.leading)
                        .vAlign(.top)
                        .padding(20)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text("Cancel")
                                        .fixedSize()
                                        .foregroundColor(Color("Blue"))
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isPresentedEditing = true
//                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Text("Edit")
                                        .fixedSize()
                                        .foregroundColor(Color("Blue"))
                                }
                            }
                        }
                    }.sheet(isPresented: $isPresentedEditing) {
                        NewSessionView(activity: $activity, isEditing: true)
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
