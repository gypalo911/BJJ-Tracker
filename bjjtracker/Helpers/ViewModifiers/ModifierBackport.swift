//
//  ModifierAvailability.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 07.08.2023.
//

import SwiftUI

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @ViewBuilder func hiddenToolbar(_ isHidden: Bool) -> some View {
        content
            .toolbar(isHidden ? .hidden : .visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
    }
}
