//
//  AddMoreTagView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct AddMoreTagView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image("addIcon")
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(Color("Blue"))
            Text("Add technique")
                .font(Font.custom("Rubik", size: 14))
                .foregroundColor(Color("Blue"))
        }
        .padding(.vertical, 5)
        .padding(.leading, 5)
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
