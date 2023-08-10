//
//  ViewSizeModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 03.08.2023.
//

import SwiftUI

struct ViewSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewSizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: ViewSizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }
}

extension View {
    func getSize(perform: @escaping (CGSize) -> ()) -> some View {
        self
            .modifier(ViewSizeModifier())
            .onPreferenceChange(ViewSizePreferenceKey.self) {
                perform($0)
            }
    }
}
