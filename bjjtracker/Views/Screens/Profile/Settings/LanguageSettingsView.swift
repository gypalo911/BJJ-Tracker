//
//  LanguageSettingsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 04.08.2023.
//

import SwiftUI

private enum LanguageSettingsLocalisation {
    static let language = "Language"
}

struct LanguageSettingsView: View {
    
    @EnvironmentObject var settings: AppSettings
    @State private var appLanguage: AppSettings.AppLanguage = .english
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 40, height: 40)
                        .background(Color(red: 0.96, green: 0.97, blue: 1))
                        .cornerRadius(10)
                    Image("language")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.black)
                        .frame(width: 20, height: 20)
                }
                Text(LanguageSettingsLocalisation.language.localizedString)
                    .font(.body)
                    .fontWeight(.bold)
            }
            .hAlign(.leading)
            
            RadioButton(isSelected: appLanguage == .ukrainian, text: AppSettings.AppLanguage.ukrainian.stringValue) {
                appLanguage = .ukrainian
            }
            RadioButton(isSelected: appLanguage == .english, text: AppSettings.AppLanguage.english.stringValue) {
                appLanguage = .english
            }
        }
        .padding(20)
        .onAppear {
            appLanguage = settings.appLanguage
        }
        .onDisappear {
            settings.appLanguage = appLanguage
        }
    }
}

struct RadioButton: View {
    let isSelected: Bool
    let text: String
    var onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(maxWidth: 330)
                .frame(height: 40)
                .foregroundColor(isSelected ? .black : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 0.5)
                        .stroke(isSelected ? .clear : .black, lineWidth: 1)
                )
            
            HStack {
                ZStack {
                    Circle()
                        .stroke(isSelected ? .white : .black, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(isSelected ? .white : .clear)
                        .frame(width: 10, height: 10)
                }
                Text(text.localizedString)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.horizontal, 22)
            .hAlign(.leading)
        }
        .animation(.easeInOut(duration: 0.25), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

struct LanguageSettingsView_Previews: PreviewProvider {
    struct Container: View {
        @State private var isShowingOverlay: Bool = true
        
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
                                    isShowingOverlay = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(
                    isPresented: $isShowingOverlay) {
                        LanguageSettingsView()
                    }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
    }
}
