//
//  ConnectAppleHealthView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct ConnectAppleHealthView: View {
    enum Localisation {
        static let trainSmarter = "Train smarter by connecting your JiuTrack app to Apple Health"
        static let permissions = "Apple Health integration requires permissions to be granted in **Settings -> Privacy -> Health -> JiuTrack**"
        static let connect = "Connect"
    }

    var onConnect: (() -> Void)
    
    var body: some View {
        VStack(spacing: 25) {
            Image("apple-health-2x")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(Localisation.trainSmarter.localizedString)
                .font(heading: .h5)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(text: .text)
            
            Text(Localisation.permissions.localizedString)
                .font(subtext: .light)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(text: .tertiary)
            
            
            Button(action: {
                onConnect()
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(promotional: .deals)
                        .frame(maxWidth: 270)
                        .frame(height: 40)
                        .defaultShadow()
                    HStack {
                        Text(Localisation.connect.localizedString)
                            .font(buttons: .regular)
                            .fontWeight(.medium)
                            .foregroundStyle(text: .onColor)
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
                        DefaultHealthKitService().authorizeHealthKitIfNeeded { _ in
                            showingActionSheet = false
                        }
                    })
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
