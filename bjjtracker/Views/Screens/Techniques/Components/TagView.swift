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
    
    @Namespace var animation
    var maxViewWidth: CGFloat
    
    var body: some View {
        Text(tag.text)
            .font(Font.custom("Rubik", size: 14))
            .foregroundColor(Color("Blue"))
            .padding(.vertical, 8)
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(
                ZStack(alignment: .trailing) {
                    Capsule()
                        .fill(Color("LightBlue1"))
                }
            )
            .contentShape(.contextMenuPreview, Capsule())
            .contextMenu {
                Button("Delete", action: {
                    onDelete?(tag.id)
                })
            }
            .matchedGeometryEffect(id: tag.id, in: animation)
    }
}

struct TagView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            TagView(
                tag: .init(text: "Delariva"),
                onDelete: { _ in },
                maxViewWidth: UIScreen.main.bounds.size.width
            ).padding(30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
