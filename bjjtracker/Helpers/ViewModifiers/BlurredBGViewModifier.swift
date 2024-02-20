//
//  BlurredBGViewModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.07.2023.
//

import SwiftUI

struct BlurredBGViewModifier<InnerView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder let view: InnerView
    @State private var blurRadius: CGFloat = 50
    
    func body(content: Content) -> some View {
        Group {
            content
                .blur(radius: isPresented ? blurRadius : 0, opaque: false)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            if isPresented {
                view
            }
        }
    }
}

extension View {
    func blurredPopup(isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> some View) -> some View {
        return modifier(BlurredBGViewModifier(isPresented: isPresented, view: view))
    }
}
