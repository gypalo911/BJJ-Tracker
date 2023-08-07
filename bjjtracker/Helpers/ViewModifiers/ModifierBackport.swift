//
//  ModifierAvailability.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 07.08.2023.
//

import SwiftUI
import Introspect

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @ViewBuilder func hiddenToolbar(_ isHidden: Bool) -> some View {
        if #available(iOS 16, *) {
            content
                .toolbar(isHidden ? .hidden : .visible, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .introspectNavigationController(customize: { (UINavigationController) in
                    UINavigationController.navigationBar.isHidden = true
                })
        } else {
            content
                .navigationBarHidden(isHidden)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .introspectNavigationController(customize: { (UINavigationController) in
                    UINavigationController.navigationBar.isHidden = true
                })
        }
    }
}
