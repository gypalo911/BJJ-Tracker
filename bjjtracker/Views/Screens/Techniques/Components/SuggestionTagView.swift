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
            .font(Font.custom("Rubik", size: 14))
            .foregroundColor(Color("DefaultBlue"))
            .padding(.vertical, 8)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(
                ZStack {
                    Capsule()
                        .fill(Color.white)
                    Capsule()
                        .stroke(Color("DefaultBlue"), lineWidth: 1)
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
