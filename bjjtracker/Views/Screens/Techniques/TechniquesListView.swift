//
//  TechniquesListView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TechniquesListView: View {
    
    @StateObject var viewModel = ContentViewModel()
    
    @State private var isEditing: Bool = false
    @State private var isTyping: Bool = false
    @State private var maxViewWidth: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.rows, id: \.self) { rows in
                    HStack(spacing: 10) {
                        ForEach(rows) { row in
                            TagView(
                                tag: row,
                                onDelete: { tagId in
                                    viewModel.removeTag(by: tagId)
                                },
                                maxViewWidth: maxViewWidth
                            )
                        }
                    }.hAlign(.leading)
                }
                
                VStack {
                    if isTyping {
                        TagViewWithTextField(
                            isEditing: $isTyping,
                            onSubmit: { tag in
                                viewModel.add(tag: tag)
                            },
                            maxViewWidth: maxViewWidth
                        )
                        .padding (.horizontal, 15)
                    } else {
                        AddMoreTagView()
                            .padding (.horizontal, 1)
                            .padding (.bottom, 5)
                            .onTapGesture {
                                isTyping = true
                            }
                    }
                }
            }
            .padding([.leading, .top], 10)
            .animation(.easeInOut(duration: 0.3), value: viewModel.rows)
        }
        .padding(.vertical, 10)
        .onAppear {
            maxViewWidth = UIScreen.main.bounds.size.width - 80
            viewModel.maxRowWidth = maxViewWidth
            viewModel.getTags()
        }
    }
}

struct TechniquesListView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            TechniquesListView()
                .padding(30)
        }
    }
    
    static var previews: some View {
        Container()
    }
}
