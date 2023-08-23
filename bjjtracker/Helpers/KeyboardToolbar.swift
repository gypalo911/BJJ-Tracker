//
//  KeyboardToolbar.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.07.2023.
//

import SwiftUI

struct KeyboardToolbar<ToolbarView: View>: ViewModifier {
    private let height: CGFloat
    private let toolbarView: ToolbarView
    
    init(height: CGFloat, @ViewBuilder toolbar: () -> ToolbarView) {
        self.height = height
        self.toolbarView = toolbar()
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                VStack {
                    content
                }
                .frame(width: geometry.size.width, height: geometry.size.height - height)
            }
            toolbarView
                .frame(height: self.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


extension View {
    func keyboardToolbar<ToolbarView>(height: CGFloat, view: @escaping () -> ToolbarView) -> some View where ToolbarView: View {
        modifier(KeyboardToolbar(height: height, toolbar: view))
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
