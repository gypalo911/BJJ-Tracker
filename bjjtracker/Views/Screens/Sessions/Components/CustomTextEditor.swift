//
//  CustomTextEditor.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.05.2023.
//

import SwiftUI

struct CustomTextEditor: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextEditor(text: $text)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 0.01)
                        .stroke(Color("LightGray"), lineWidth: 2)
                )
                .frame(minHeight: 150, alignment: .top)
                .padding(.leading, 5)
                .focused($isFocused)
            if text.isEmpty {
                VStack {
                    Text("Add some details...".localizedString)
                        .font(.body)
                        .foregroundColor(Color("GrayTextColor"))
                        .padding(20)
                    Spacer()
                }
            }
        }
        .onTapGesture {
            isFocused = true
        }
    }
}

struct CustomTextEditor_Previews: PreviewProvider {
    struct Container: View {
        @State var text: String = ""
        
        var body: some View {
            CustomTextEditor(text: $text)
                .frame(height: 200)
                .padding(20)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
