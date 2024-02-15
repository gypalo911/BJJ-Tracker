//
//  ShareSessionView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 15.02.2024.
//

import SwiftUI

enum LayoutType {
    case one
    case two
    case three
}

struct ShareSessionView: View {
    @State var layoutType: LayoutType = .two
    
    var body: some View {
        let trophyAndDate = createAwardView()
        
        NavigationView {
            VStack {
                trophyAndDate
                //            Button("Save image") {
                //                
                //                if #available(iOS 16.0, *) {
                //                    let renderer = ImageRenderer(content: trophyAndDate)
                //                    if let image = renderer.cgImage {
                //                        //                    uploadAchievementImage(image)
                //                    }
                //                } else {
                //                    // Fallback on earlier versions
                //                }
                //            }
                HStack {
                    Button("layout 1") {
                        layoutType = .one
                    }
                    Button("layout 2") {
                        layoutType = .two
                    }
                    Button("layout 3") {
                        layoutType = .three
                    }
                }
                .padding(.bottom, 30)
            }
            //        .ignoresSafeArea()
            //        .frame(width: 200, height: 400)
        }
    }
    
    private func createAwardView() -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Image("bjj")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    
                layout(type: layoutType, geometry: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func layout(type: LayoutType, geometry: GeometryProxy) -> some View {
        switch type {
        case .one:
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("JiuTrack")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 5)
            .background(Color("LogoColor"))
            .rotationEffect(.degrees(90))
            .position(x: geometry.size.width-20, y: geometry.size.height/5)
            
            VStack(alignment: .leading) {
                Text("No-Ji Class")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(Date().formatted())
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .position(x: 100, y: 40)
            
            VStack(alignment: .trailing, spacing: 20) {
                VStack(alignment: .trailing) {
                    Text(100.minutesToDuration())
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Duration")
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
                VStack(alignment: .trailing) {
                    Text("**1200 kcal**")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Calories")
                        .font(.title3)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
            .position(x: geometry.size.width-80, y: geometry.size.height-120)
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
            )
        case .two:
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("JiuTrack")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 5)
            .background(Color("LogoColor"))
            .position(x: 80, y: 30)
            
            ZStack {
                VStack(alignment: .center) {
                    Text("No-Ji Class")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .position(x: geometry.size.width/2, y: geometry.size.height - 110)
                
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center) {
                        Text(100.minutesToDuration())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                    VStack(alignment: .center) {
                        Text("**1200 kcal**")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Calories")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                }
                .position(x: geometry.size.width/2, y: geometry.size.height - 50)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.white.opacity(0), .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
            )
        case .three:
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("JiuTrack")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 5)
            .background(Color("LogoColor"))
            .rotationEffect(.degrees(90))
            .position(x: geometry.size.width-20, y: geometry.size.height/5)
            
            VStack(alignment: .leading) {
                Text("No-Ji Class")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(Date().formatted())
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .position(x: 100, y: 40)
        }
    }
}

#Preview {
    ShareSessionView()
}
