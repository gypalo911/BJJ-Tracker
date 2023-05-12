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
                .colorMultiply(Color("LightBlue"))
                .frame(minHeight: 150, alignment: .top)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("LightBlue"))
                )
                .padding(.leading, 5)
                .focused($isFocused)
            if text.isEmpty {
                VStack {
                    Text("Add some details...".localizedString)
                        .font(.custom("Helvetica", size: 18))
                        .foregroundColor(Color("GrayTextColor"))
                        .padding(30)
                    Spacer()
                }
                .onTapGesture {
                    isFocused = true
                }
            }
        }
    }
}
