//
//  AddMoreTagView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct AddMoreTagView: View {
    private enum Localisation {
        static var addTechnique: String { "Add technique".localizedString }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image("addIcon")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(DesignSystem.shared.colors.brand.primary)
            Text(Localisation.addTechnique)
                .font(DesignSystem.shared.fonts.chip.swiftUI)
                .foregroundColor(DesignSystem.shared.colors.text.primary)
        }
        .padding(.vertical, 6)
        .padding(.leading, DesignSystem.shared.spacing.small)
        .padding(.trailing, DesignSystem.shared.spacing.buttonHorizontal)
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 2)
                        .fill(DesignSystem.shared.colors.border.primary)
                )
        )
    }
}

struct AddMoreTagView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            AddMoreTagView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}
