//
//  BottomSheetModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 04.08.2023.
//

import SwiftUI

struct BottomSheetModifier<InnerView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    @ViewBuilder let view: InnerView
    
    private let blurRadius: CGFloat = 5
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: isPresented ? blurRadius : 0, opaque: true)
            .overlay(alignment: .bottom) {
                if isPresented {
                    GenericBottomSheet(view: view, isBottomSheetOpen: $isPresented)
                }
            }
            .edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func bottomSheet(isPresented: Binding<Bool>, @ViewBuilder view: @escaping () -> some View) -> some View {
        return modifier(BottomSheetModifier(isPresented: isPresented, view: view))
    }
}
