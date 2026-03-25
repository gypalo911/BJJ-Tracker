//
//  Font + View.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

extension View {
    /// Provides a basic Body style for the Text
    /// - Parameter body: Font variation
    /// - Returns: Returns the modified View
    func font(body: DesignSystem.Typography.Body) -> some View {
        font(fontType: body.token.swiftUI)
    }

    /// Provides a basic Heading style for the Text
    /// - Parameter heading: Font variation
    /// - Returns: Returns the modified View
    func font(heading: DesignSystem.Typography.Heading) -> some View {
        font(fontType: heading.token.swiftUI)
    }

    /// Provides a basic Buttons style for the Text
    /// - Parameter buttons: Font variation
    /// - Returns: Returns the modified View
    func font(buttons: DesignSystem.Typography.Buttons) -> some View {
        font(fontType: buttons.token.swiftUI)
    }

    /// Provides a basic SubText style for the Text
    /// - Parameter subtext: Font variation
    /// - Returns: Returns the modified View
    func font(subtext: DesignSystem.Typography.SubText) -> some View {
        font(fontType: subtext.token.swiftUI)
    }

    /// Provides a basic strikethrough style for text
    /// - Parameter strikethrough: Font variation
    /// - Returns: Returns the modified View
    func font(strikethrough: DesignSystem.Typography.Strikethrough) -> some View {
        font(fontType: strikethrough.token.swiftUI)
            .strikethrough()
    }
}

// MARK: - Private

private extension View {
    /// Allows us to enable/disable Dynamic Text on a Development Environment
    /// - Parameters:
    ///     - fontType: Font type that we pass
    ///     - range: The minimum and maximum value for the dynamic text sizes
    /// - Returns: Returns the modified View with or without dynamic text applied
    func font(
        fontType font: Font,
        range: any RangeExpression<DynamicTypeSize> = DynamicTypeSize.xSmall ... DynamicTypeSize.xxxLarge
    ) -> some View {
        self
            .font(font)
            .disableAccessibilitySizes(range)
    }
}
