//
//  BlurredBGViewModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.07.2023.
//

import SwiftUI

struct BlurredBGViewModifier<InnerView: View>: ViewModifier {
    
    @ViewBuilder let view: InnerView
    @State private var blurRadius: CGFloat = 50
    @Binding var showingOverlay: Bool
    
    func body(content: Content) -> some View {
        Group {
            content
                .blur(radius: showingOverlay ? blurRadius : 0, opaque: true)
                .animation(.easeInOut(duration: 0.25), value: showingOverlay)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            if showingOverlay {
                view
            }
        }
    }
}

extension View {
    func blurredPopup(@ViewBuilder view: (() -> some View), showingOverlay: Binding<Bool>) -> some View {
        return modifier(BlurredBGViewModifier(view: view, showingOverlay: showingOverlay))
    }
}
