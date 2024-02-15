//
//  BouncyButton.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 15.02.2024.
//

import SwiftUI

struct BouncyButton: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        return configuration.label
            .scaleEffect(x: configuration.isPressed ? 0.75 : 1.0, y: configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
