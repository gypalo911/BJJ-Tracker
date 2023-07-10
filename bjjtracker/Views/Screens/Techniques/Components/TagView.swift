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
    let tag: Tag
    let onDelete: ((String) -> Void)?

    @State var isSelected: Bool = false
    @Binding var isEditing: Bool
    
    var maxViewWidth: CGFloat
    
    var body: some View {
        Text(tag.text)
            .font(Font.custom("Rubik", size: 14))
            .foregroundColor(isSelected ? .white : Color("Blue"))
            .padding(.vertical, 8)
            .padding(.leading, 20)
            .padding(.trailing, isEditing ? 30 : 20)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(
                ZStack(alignment: .trailing) {
                    Capsule()
                        .fill(isSelected ? Color("Blue") : Color("LightBlue1"))
                    if isEditing {
                        Button {
                            onDelete?(tag.id)
                        } label:{
                            Image(systemName: "xmark")
                                .frame(width: 15, height: 15)
                                .padding(.trailing, 10)
                                .foregroundColor(.red)
                        }
                    }
                }
            )
    }
}

struct TagView_Previews: PreviewProvider {
    struct Container: View {
        @State var isEditing = false
        
        var body: some View {
            TagView(
                tag: .init(text: "Delariva"),
                onDelete: { _ in },
                isEditing: $isEditing,
                maxViewWidth: UIScreen.main.bounds.size.width
            ).onLongPressGesture {
                isEditing.toggle()
            }.padding(30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
