//
//  TagViewWithTextField.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TagViewWithTextField: View {
    private enum Localisation {
        static var technique: String { "Technique".localizedString }
    }

    @State private var defaultViewWidth: CGFloat = 70
    @Binding var tag: Tag
    @State var viewWidth: CGFloat = 70
    @Binding var isEditing: Bool
    @FocusState private var focusedField: Bool
    
    let onSubmit: ((Tag) -> Void)?
    
    var maxViewWidth: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(DesignSystem.shared.colors.brand.primary)
                .cornerRadius(30)
            TextField(
                "",
                text: $tag.text,
                prompt:
                    Text(Localisation.technique)
                        .foregroundColor(DesignSystem.shared.colors.text.placeholder)
            )
            .focused($focusedField)
            .autocorrectionDisabled(true)
            .foregroundColor(DesignSystem.shared.colors.text.inverse)
            .accentColor(DesignSystem.shared.colors.text.inverse)
            .font(DesignSystem.shared.fonts.chip.swiftUI)
            .fixedSize()
            .padding(.horizontal, DesignSystem.shared.spacing.chipInputHorizontal)
            .padding(.vertical, DesignSystem.shared.spacing.chipVertical)
            .onAppear {
                focusedField = true
            }
            .onSubmit {
                withAnimation(.easeInOut) {
                    isEditing = false
                }
                tag.size = tag.text.textSize().width + 25
                onSubmit?(tag)
                tag = .init(text: "")
            }
            .onChange(of: tag.text) { _, newValue in
                let font = DesignSystem.shared.fonts.chip.uiKit
                let size = newValue.textSize(font)
                
                tag.text = String(newValue.prefix(40))
                
                if newValue.textSize().width + 20 > maxViewWidth {
                    viewWidth = maxViewWidth
                } else if size.width == 0 {
                    viewWidth = defaultViewWidth
                } else {
                    viewWidth = size.width
                }
            }
        }
        .onAppear {
            defaultViewWidth = Localisation.technique.textSize().width
            viewWidth = defaultViewWidth
        }
        .frame(height: 30)
        .fixedSize()
    }
}

struct TagViewWithTextField_Previews: PreviewProvider {
    struct Container: View {
        @State var isEditing = false
        @State var tag: Tag = .init(text: "")
        var body: some View {
            TagViewWithTextField(
                tag: $tag, 
                isEditing: $isEditing,
                onSubmit: { tag in },
                maxViewWidth: UIScreen.main.bounds.size.width - 80
            )
        }
    }
    
    static var previews: some View {
        Container()
            .environment(\.locale, .init(identifier: "uk"))
    }
}
