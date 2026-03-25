//
//  ForegroundColor + View.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

extension View {
    /// Returns a color from the Background color set
    /// - Parameter background: A color from the Background color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        background: DesignSystem.Color.Background,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(background.color.opacity(opacity))
    }

    /// Returns a color from the Border color set
    /// - Parameter border: A color from the Border color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        border: DesignSystem.Color.Border,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(border.color.opacity(opacity))
    }

    /// Returns a color from the Disabled color set
    /// - Parameter disabled: A color from the Disabled color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        disabled: DesignSystem.Color.Disabled,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(disabled.color.opacity(opacity))
    }

    /// Returns a color from the Icon color set
    /// - Parameter icon: A color from the Icon color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        icon: DesignSystem.Color.Icon,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(icon.color.opacity(opacity))
    }

    /// Returns a color from the Overlay color set
    /// - Parameter overlay: A color from the Overlay color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        overlay: DesignSystem.Color.Overlay,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(overlay.color.opacity(opacity))
    }

    /// Returns a color from the Pressed color set
    /// - Parameter pressed: A color from the Pressed color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        pressed: DesignSystem.Color.Pressed,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(pressed.color.opacity(opacity))
    }

    /// Returns a color from the Promotional color set
    /// - Parameter promotional: A color from the Promotional color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        promotional: DesignSystem.Color.Promotional,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(promotional.color.opacity(opacity))
    }

    /// Returns a color from the Selected color set
    /// - Parameter selected: A color from the Selected color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        selected: DesignSystem.Color.Selected,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(selected.color.opacity(opacity))
    }

    /// Returns a color from the Skeleton color set
    /// - Parameter skeleton: A color from the Skeleton color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        skeleton: DesignSystem.Color.Skeleton,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(skeleton.color.opacity(opacity))
    }

    /// Returns a color from the Specific color set
    /// - Parameter specific: A color from the Specific color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        specific: DesignSystem.Color.Specific,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(specific.color.opacity(opacity))
    }

    /// Returns a color from the Status color set
    /// - Parameter status: A color from the Status color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        status: DesignSystem.Color.Status,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(status.color.opacity(opacity))
    }

    /// Returns a color from the Text color set
    /// - Parameter text: A color from the Text color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        text: DesignSystem.Color.Text,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(text.color.opacity(opacity))
    }

    /// Returns a color from the UI color set
    /// - Parameter ui: A color from the UI color set
    /// - Returns: Returns the modified View
    func foregroundStyle(
        ui: DesignSystem.Color.UI,
        opacity: Double = 1.0
    ) -> some View {
        self.foregroundStyle(ui.color.opacity(opacity))
    }
}
