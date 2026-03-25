//
//  BluredBottomSheet.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.07.2023.
//

import SwiftUI

struct BluredBottomSheet: View {
    enum Localisation {
        static let newSession = "New Session"
        static let newPromotion = "New Promotion"
        static let newTechnique = "New Technique"
    }

    @Binding var isBottomSheetOpen: Bool
    @State private var offset: CGFloat = 100
    @State private var popupOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    
    let buttonAnimation: Animation = Animation.easeInOut(duration: 0.25)
    
    var onSelect: ((ModalSheets?) -> ())?
    
    var body: some View {
        ZStack {
            Color.primary
                .opacity (0.01)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isBottomSheetOpen = false
                    }
                }
            Group {
                VStack(spacing: 10) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 60, height: 4)
                        .background(.white)
                        .cornerRadius(20)
                        .defaultShadow()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 0.01)
                                .stroke(.black, lineWidth: 0.01)
                        )
                        .padding(.bottom, 5)
                        .opacity(offset != 0 ? 0 : 1)
                        .offset(x: 0.0, y: offset)
                        .animation(.easeInOut(duration: 0.2), value: offset)
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(ui: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .defaultShadow()
                        HStack {
                            Image("kimono")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(text: .onColor)
                                .frame(width: 25, height: 25)
                            Text(Localisation.newSession.localizedString)
                                .foregroundStyle(text: .onColor)
                                .font(buttons: .regular, weight: .medium)
                        }
                    }
                    .opacity(offset != 0 ? 0 : 1)
                    .offset(x: 0.0, y: offset)
                    .animation(buttonAnimation, value: offset)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isBottomSheetOpen = false
                            onSelect?(.activity)
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .defaultShadow()
                        HStack {
                            Image("beltIcon")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.black)
                                .frame(width: 25, height: 25)
                            Text(Localisation.newPromotion.localizedString)
                                .foregroundStyle(.black)
                                .font(buttons: .regular, weight: .medium)
                        }
                    }
                    .opacity(offset != 0 ? 0 : 1)
                    .offset(x: 0.0, y: offset)
                    .animation(buttonAnimation.delay(0.1), value: offset)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isBottomSheetOpen = false
                            onSelect?(.promotion)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(status: .successStrong)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .defaultShadow()
                        HStack {
                            Image("triangle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                            Text(Localisation.newTechnique.localizedString)
                                .foregroundStyle(text: .onColor)
                                .font(buttons: .regular, weight: .medium)
                        }
                    }
                    .opacity(offset != 0 ? 0 : 1)
                    .offset(x: 0.0, y: offset)
                    .animation(buttonAnimation.delay(0.2), value: offset)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isBottomSheetOpen = false
                            onSelect?(nil)
                        }
                    }
                }
                .foregroundColor(.clear)
                .padding(.horizontal, 20)
                .onAppear {
                    withAnimation(.easeInOut) {
                        self.offset = 0
                    }
                }
            }
            .padding(.bottom, 50)
            .frame(maxWidth: 400)
            .contentShape(Rectangle())
            .vAlign(.bottom)
            .hAlign(.center)
            .offset(x: 0.0, y: popupOffset)
            .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                if value.translation.height > -100 {
                    out = value.translation.height
                    onChange()
                }
            }).onEnded { value in
                if value.translation.height > 100 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isBottomSheetOpen = false
                    }
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    popupOffset = 0
                }
            })
        }
    }
    
    private func onChange() {
        DispatchQueue.main.async {
            self.popupOffset = gestureOffset
        }
    }
}



struct BluredBottomSheet_Previews: PreviewProvider {
    struct Container: View {
        @EnvironmentObject var settings: AppSettings
        
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
                                    settings.showingActionSheet = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .blurredPopup(
                    isPresented: $settings.showingActionSheet) {
                        BluredBottomSheet(
                            isBottomSheetOpen: $settings.showingActionSheet,
                            onSelect: { modal in
                            }
                        )
                    }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
        //        BluredBottomSheet()
    }
}
