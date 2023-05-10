//
//  ProfileView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI

struct ProfileView: View {
    @State private var showAddPromotionSheet: Bool = false
    
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
                        .font(.system(size: 16))
                        .fontWeight(.medium)
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
                            }
                            .padding([.leading, .top, .trailing], 15)
                            
                            VStack {
                                BeltProgressCell(belt: .white, sessionsCount: 100, stripesCount: 4)
                                
                                BeltProgressCell(belt: .blue, sessionsCount: 20, stripesCount: 0)
                                BeltProgressCell(belt: .purple, sessionsCount: 0, stripesCount: 0)
                                BeltProgressCell(belt: .brown, sessionsCount: 0, stripesCount: 0)
                                BeltProgressCell(belt: .black, sessionsCount: 0, stripesCount: 0)
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
            .sheet(isPresented: $showAddPromotionSheet) {
                AddPromotionView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct BeltProgressCell: View {
    var belt: AdultBelts
    var sessionsCount: Int
    var stripesCount: Int
    
    @State var showPromotionsList: Bool = false
    @State var promotions: [Promotion] = [
        .init(gradingSystem: .adult, adultBelt: .white, stripes: 0, date: Date(), location: "", notes: ""),
        .init(gradingSystem: .adult, adultBelt: .white, stripes: 1, date: Date(), location: "", notes: ""),
        .init(gradingSystem: .adult, adultBelt: .white, stripes: 2, date: Date(), location: "", notes: "")
    ]
    
    var showListBG: Bool {
        showPromotionsList && !promotions.isEmpty
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            CircularBeltView(
                                primaryColor: belt.color.0,
                                secondaryColor: belt.color.1
                            )
                            if sessionsCount == 0 {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 36)
                                Image("lock")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                        }
                        
                        
                        Text("\(belt.rawValue) belt")
                    }
                    Spacer()
                    if !promotions.isEmpty && sessionsCount > 0 {
                        Image("info")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if sessionsCount > 0 && !promotions.isEmpty {
                            showPromotionsList.toggle()
                        }
                    }
                }
                if belt != .black {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
                if sessionsCount > 0 && showPromotionsList {
                    BeltPromotionsList(promotions: $promotions)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(showListBG ? Color("listBG") : Color.white)
        )
    }
}

struct BeltView: View {
    var beltWidth: CGFloat = 210
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
                .frame(width: beltWidth, height: 36)
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

struct CircularBeltView: View {
    let primaryColor: Color
    let secondaryColor: Color?
    var isSelected: Bool = true
    var height: CGFloat = 36
    
    var strokeColor: Color {
        return isSelected ? Color.black : Color.gray
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: 2)
                )
                .frame(width: height, height: height)
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .fill(primaryColor)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(strokeColor, lineWidth: 2)
                    )
                    .frame(width: height - 8, height: height - 8)
            }
            .rotationEffect(.degrees(-90))
            
            if let secondaryColor = secondaryColor {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .fill(secondaryColor)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.5)
                                .stroke(strokeColor, lineWidth: 2)
                        )
                        .frame(width: height - 8, height: height - 8)
                }
                .rotationEffect(.degrees(90))
            }
            Rectangle()
                .fill(strokeColor)
                .frame(width: 2, height: height - 6)
        }
    }
}

struct BeltPromotionsList: View {
    @Binding var promotions: [Promotion]
    
    var body: some View {
        List {
            ForEach(promotions, id: \.id) { promotion in
                BeltPromotionsListCell(stripes: promotion.stripes, date: promotion.date)
                    .padding(5)
            }.onDelete { offset in
                withAnimation(.easeInOut(duration: 0.3)) {
                    promotions.remove(atOffsets: offset)
                }
            }
            .background(Color("listBG"))
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(.zero))
        }
        .listStyle(.plain)
        .frame(minHeight: 50 * CGFloat(promotions.count))
    }
}

struct BeltPromotionsListCell: View {
    let stripes: Int
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 10)
                Text("Stripes: \(stripes)")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            Text(date.toString("dd MMM yyyy"))
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
                .padding(.leading, 20)
        }
        .padding(.horizontal, 20)
        .hAlign(.leading)
    }
}
