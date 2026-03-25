//
//  SuggestionTagView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 12.07.2023.
//

import SwiftUI

struct SuggestionTagView: View {
    let tag: Tag
    let onTap: (() -> Void)?
    
    @Namespace var animation
    
    var body: some View {
        Text(tag.text)
            .font(DesignSystem.shared.fonts.chip.swiftUI)
            .foregroundColor(DesignSystem.shared.colors.text.primary)
            .padding(.vertical, DesignSystem.shared.spacing.chipVertical)
            .padding(.horizontal, DesignSystem.shared.spacing.chipHorizontal)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(
                ZStack {
                    Capsule()
                        .fill(Color.white)
                    Capsule()
                        .stroke(DesignSystem.shared.colors.border.primary, lineWidth: 1)
                }
            )
            .matchedGeometryEffect(id: tag.id, in: animation)
            .onTapGesture {
                onTap?()
            }
    }
}

struct SuggestionTagView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            SuggestionTagView(
                tag: .init(text: "Delariva"),
                onTap: {}
            ).padding(30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
