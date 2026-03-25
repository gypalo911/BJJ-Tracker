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
                .foregroundColor(Color("Blue"))
            Text(Localisation.addTechnique)
                .font(Font.custom("Rubik", size: 14))
                .foregroundColor(Color("Blue"))
        }
        .padding(.vertical, 6)
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(30)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 2)
                        .fill(Color("Blue"))
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
