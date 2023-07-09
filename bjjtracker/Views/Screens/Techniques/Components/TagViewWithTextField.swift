//
//  TagViewWithTextField.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TagViewWithTextField: View {
    private static let defaultViewWidth: CGFloat = 70
    @State var tag: Tag = .init(text: "")
    @State var viewWidth: CGFloat = defaultViewWidth
    @Binding var isEditing: Bool
    @FocusState private var focusedField: Bool
    
    let onSubmit: ((Tag) -> Void)?
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("Blue"))
                .cornerRadius(30)
            TextField(
                "",
                text: $tag.text,
                prompt:
                    Text("Technique")
                    .foregroundColor(Color("LightGray"))
            )
            .focused($focusedField)
            .foregroundColor(.white)
            .accentColor(.white)
            .font(Font.custom("Rubik", size: 14))
            .frame(width: viewWidth)
            .padding (.horizontal)
            .onAppear {
                focusedField = true
            }
            .onSubmit {
                isEditing = false
                tag.size = tag.text.textSize().width + 40
                onSubmit?(tag)
                tag = .init(text: "")
            }
            .onChange(of: tag.text) { newValue in
                let font = UIFont.systemFont(ofSize: 14)
                let size = newValue.textSize(font)
                
                if size.width == 0 {
                    viewWidth = TagViewWithTextField.defaultViewWidth
                } else if size.width <= 150 {
                    viewWidth = size.width
                }
            }
        }
        .frame(width: viewWidth, height: 30)
    }
}

struct TagViewWithTextField_Previews: PreviewProvider {
    struct Container: View {
        @State var isEditing = false
        var body: some View {
            TagViewWithTextField(isEditing: $isEditing, onSubmit: { tag in })
        }
    }
    
    static var previews: some View {
        Container()
    }
}

