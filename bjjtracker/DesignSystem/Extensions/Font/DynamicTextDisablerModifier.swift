//
//  DynamicTextDisablerModifier.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

/// Dynamic Text Modifier
///
/// Allows us to disable/enable Dynamic Text for the app.
struct DynamicTextDisablerModifier: ViewModifier {
    let range: any RangeExpression<DynamicTypeSize>

    init(range: any RangeExpression<DynamicTypeSize>) {
        self.range = range
    }

    func body(content: Content) -> some View {
        content.dynamicTypeSize(.xSmall ... .xxxLarge)
    }
}

// MARK: - View

extension View {
    func disableAccessibilitySizes(_ range: any RangeExpression<DynamicTypeSize>) -> some View {
        modifier(DynamicTextDisablerModifier(range: range))
    }
}

// MARK: - Text

extension Text {
    func disableAccessibilitySizes(_ range: any RangeExpression<DynamicTypeSize>) -> Text {
        modifier(DynamicTextDisablerModifier(range: range))
            .content
    }
}
