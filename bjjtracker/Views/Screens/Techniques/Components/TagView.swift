//
//  TagView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct Tag: Identifiable, Hashable {
    var id = UUID().uuidString
    var text: String
    var size: CGFloat = 0
}

struct TagView: View {
    @State var isSelected: Bool = false
    let tag: Tag
    
    var body: some View {
            Text(tag.text)
              .font(Font.custom("Rubik", size: 14))
              .foregroundColor(isSelected ? .white : Color("Blue"))
              .padding(.vertical, 8)
              .padding(.horizontal, 15)
//              .frame(minWidth: tag.size)
              .fixedSize()
              .background(
                Rectangle()
                  .foregroundColor(isSelected ? Color("Blue") : Color("LightBlue1"))
                  .cornerRadius(30)
              )
    }
}

struct TagView_Previews: PreviewProvider {
    struct Container: View {
        var body: some View {
            TagView(tag: .init(text: "Delariva", size: 110))
        }
    }
    
    static var previews: some View {
        Container()
    }
}
