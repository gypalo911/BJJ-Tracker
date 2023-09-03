//
//  GenericBottomSheet.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 04.08.2023.
//

import SwiftUI

struct GenericBottomSheet<Content: View>: View {
    let view: Content
    
    private let deafultOffset: CGFloat = 100
    @Binding var isBottomSheetOpen: Bool
    @State private var offset: CGFloat = 100
    @State private var popupOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.74, green: 0.74, blue: 0.74).opacity(0.38))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 0)
                .opacity(offset != 0 ? 0 : 1)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        offset = deafultOffset
                        isBottomSheetOpen.toggle()
                    }
                }
            
            VStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 60, height: 4)
                    .cornerRadius(20)
                    .defaultShadow()
                    .padding(.bottom, 5)
                    .opacity(offset != 0 ? 0 : 1)
                    .offset(x: 0.0, y: offset)
                    .animation(.easeInOut(duration: 0.25), value: offset)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.01)
                            .stroke(.black, lineWidth: 0.01)
                    )
                
                view
                    .padding(.bottom, deafultOffset)
                    .frame(maxWidth: .infinity)
                    .background(
                        Rectangle()
                            .fill(.white)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            .offset(x: 0.0, y: offset)
                            .animation(.easeInOut(duration: 0.25), value: offset)
                            .opacity(offset != 0 ? 0 : 1)
                            .ignoresSafeArea()
                    )
                    .opacity(offset != 0 ? 0 : 1)
                    .padding(.bottom, -deafultOffset)
                    .offset(x: 0.0, y: offset)
                    .animation(.easeInOut(duration: 0.25), value: offset)
            }
            .offset(x: 0.0, y: popupOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.offset = 0
                }
            }
            .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                if value.translation.height > -deafultOffset {
                    out = value.translation.height
                    onChange()
                }
            }).onEnded { value in
                if value.translation.height > deafultOffset {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        offset = deafultOffset
                        isBottomSheetOpen.toggle()
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

struct GenericBottomSheet_Previews: PreviewProvider {
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
                                    isShowingOverlay.toggle()
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .bottomSheet(isPresented: $isShowingOverlay) {
                    LanguageSettingsView()
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
        
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .previewDevice(PreviewDevice(rawValue: "iphone 7 ios 15"))
            .previewDisplayName("iphone 7 ios 15")
    }
}
