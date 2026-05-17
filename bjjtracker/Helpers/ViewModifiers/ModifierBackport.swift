//
//  ModifierAvailability.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 07.08.2023.
//

import SwiftUI
import SwiftUIIntrospect

struct Backport<Content> {
    let content: Content
}

extension View {
    var backport: Backport<Self> { Backport(content: self) }
}

extension Backport where Content: View {
    @MainActor @ViewBuilder func hiddenToolbar(_ isHidden: Bool) -> some View {
        if #available(iOS 16, *) {
            content
                .toolbar(isHidden ? .hidden : .visible, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .introspect(.navigationView(style: .stack), on: .iOS(.v16, .v17, .v18, .v26), scope: .ancestor) { navC in
                    navC.navigationBar.isHidden = true
                }
        } else {
            content
                .navigationBarHidden(isHidden)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .introspect(.navigationView(style: .stack), on: .iOS(.v14, .v15), scope: .ancestor) { navC in
                    navC.navigationBar.isHidden = true
                }
        }
    }
}
