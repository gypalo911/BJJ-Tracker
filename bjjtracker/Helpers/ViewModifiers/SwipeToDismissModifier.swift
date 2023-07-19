//
//  SwipeToDismissModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.07.2023.
//

import SwiftUI

struct SwipeToDismissModifier: ViewModifier {
    var onDismiss: () -> Void
    @State private var offset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
//            .offset(y: offset.height)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 50 {
                            offset = gesture.translation
                        }
                    }
                    .onEnded { _ in
                        if abs(offset.height) > 100 {
                            onDismiss()
                        } else {
                            offset = .zero
                        }
                    }
            )
    }
}
