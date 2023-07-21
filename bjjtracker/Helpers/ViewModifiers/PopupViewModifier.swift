//
//  PopupViewModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.07.2023.
//

import SwiftUI

struct PopupViewModifier<InnerView: View>: ViewModifier {
    
    @ViewBuilder let view: InnerView
    @State private var blurRadius: CGFloat = 50
    @EnvironmentObject var settings: AppSettings
    
    func body(content: Content) -> some View {
        Group {
            content
                .blur(radius: settings.showingActionSheet ? blurRadius : 0, opaque: true)
                .animation(.easeInOut, value: settings.showingActionSheet)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            if settings.showingActionSheet {
                view
            }
        }
    }
}

extension View {
    func popup(@ViewBuilder view: (() -> some View)) -> some View {
        self.modifier(PopupViewModifier(view: view))
    }
}
