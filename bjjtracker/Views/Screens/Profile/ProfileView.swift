//
//  ProfileView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Profile")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding([.leading, .bottom], 20)
                    .hAlign(.leading)
                    .background(Color.white.ignoresSafeArea())
                
                VStack(spacing: 10) {
                    BeltView(belt: .white, stripesCount: 1)
                    Text("White belt 1 stripe")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .hAlign(.center)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack(spacing: 10) {
                            StatsView(text: "Sessions", value: "100")
                            StatsView(text: "Total time", value: "200h")
                        }
                        
                        VStack {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                Spacer()
                                
                                NavigationLink(destination: {
                                    AddPromotionView()
                                        .navigationBarTitle("")
                                        .navigationBarHidden(true)
                                }) {
                                    Text("Add Promotion")
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding([.leading, .top, .trailing], 15)
                            
                            VStack {
                                BelProgressCell(belt: .white, sessionsCount: 100, stripesCount: 1)
                                BelProgressCell(belt: .blue, sessionsCount: 0, stripesCount: 0)
                                BelProgressCell(belt: .purple, sessionsCount: 0, stripesCount: 0)
                                BelProgressCell(belt: .brown, sessionsCount: 0, stripesCount: 0)
                                BelProgressCell(belt: .black, sessionsCount: 0, stripesCount: 0)
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            Rectangle()
                                .fill(.white)
                                .cornerRadius(10)
                                .defaultShadow()
                        )
                    }.padding(20)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct BelProgressCell: View {
    var belt: AdultBelts
    var sessionsCount: Int
    var stripesCount: Int
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack(spacing: 10) {
                        BeltView(beltWith: 120, belt: belt, stripesCount: stripesCount)
                        Text("\(belt.rawValue) belt")
                    }
                    Spacer()
                    if sessionsCount > 0 {
                        VStack(alignment: .trailing) {
                            Text("\(sessionsCount)")
                                .font(.system(size: 16))
                            Text("sessions")
                                .font(.system(size: 12))
                        }
                    }
                }.padding(10)
                if sessionsCount > 0 {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
            }
            if sessionsCount == 0 {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray.opacity(0.25))
                Image("lock")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("Gray"))
                    .padding(.trailing, 20)
                    .hAlign(.trailing)
            }
        }
    }
}

struct BeltView: View {
    var beltWith: CGFloat = 210
    var belt: AdultBelts
    var stripesCount: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(belt.color.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Gray"), lineWidth: 1)
                )
                .frame(width: beltWith, height: 36)
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(belt.color.1 ?? .black)
                    .frame(width: 65, height: 36)
                HStack(spacing: 5) {
                    ForEach(0..<stripesCount, id: \.self) { stripe in
                        Rectangle()
                            .fill(.white)
                            .frame(width: 6)
                    }
                }
                .hAlign(.leading)
                .frame(width: 65, height: 34)
                .offset(x: 10, y: 0)
            }.offset(x: 20)
        }
    }
}
