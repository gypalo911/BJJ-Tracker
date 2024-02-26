//
//  TagView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TagView: View {
    let tag: Tag
    let onDelete: (() -> Void)?
    let onDetails: (() -> Void)?
    
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
                ZStack(alignment: .trailing) {
                    Capsule()
                        .fill(Color("LightBlue1"))
                }
            )
            .contentShape(.contextMenuPreview, Capsule())
            .contextMenu {
                Button("Details", action: {
                    onDetails?()
                })
                Divider()
                Button("Delete", role: .destructive, action: {
                    onDelete?()
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
                onDelete: {},
                onDetails: {}
            ).padding(30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
