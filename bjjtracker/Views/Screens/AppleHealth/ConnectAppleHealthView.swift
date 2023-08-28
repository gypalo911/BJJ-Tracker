//
//  ConnectAppleHealthView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct ConnectAppleHealthView: View {
    var onConnect: (() -> Void)
    
    var body: some View {
        VStack(spacing: 25) {
            Image("apple-health-2x")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text("Train smarter by connecting your JiuTrack app to Apple Health")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.black)
            
            Text("Apple Health integration requires permissions to be granted in **Settings -> Privacy -> Health -> JiuTrack**")
                .font(.footnote)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color("Gray"))
            
            
            Button(action: {
                onConnect()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("RedPink"))
                        .frame(maxWidth: 270)
                        .frame(height: 40)
                        .defaultShadow()
                    HStack {
                        Text("Connect")
                            .font(.body.smallCaps())
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
            })
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct ConnectAppleHealthView_Previews: PreviewProvider {
    struct Container: View {
        @State private var showingActionSheet = true
        
        var body: some View {
            NavigationView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global).size
                    ZStack {
                        Image("LogoWithText")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: frame.width, height: frame.height)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showingActionSheet = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(isPresented: $showingActionSheet) {
                    ConnectAppleHealthView(onConnect: {
                        DefaultHealthKitService().authorizeHealthKitIfNeeded { _ in }
                    })
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
