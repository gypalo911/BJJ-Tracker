//
//  TechniquesListView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

struct TechniquesListView: View {
    
    @State private var tags: [Tag] = [
        .init(text: "Delariva", size: 110),
        .init(text: "Spyder Guard", size: 150),
        .init(text: "Delariva", size: 110),
        .init(text: "Spyder Guard", size: 150),
        .init(text: "Delariva", size: 110),
        .init(text: "Spyder Guard", size: 150)
    ]
    
    private let tagsListSubviewSize: CGFloat = UIScreen.main.bounds.width - 60
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        let fetchedRows = getRows()
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(fetchedRows, id: \.self) { rows in
                    HStack(spacing: 10) {
                        ForEach(rows) { row in
                            TagView(tag: row)
                        }
                    }.hAlign(.leading)
                }
                
                // move it to the rest of tag views
                if isEditing {
                    TagViewWithTextField(
                        isEditing: $isEditing,
                        onSubmit: { tag in
                            if !tag.text.trimmingCharacters(in: .whitespaces).isEmpty {
                                tags.append(tag)
                            }
                        })
                    .padding(.leading, 18)
                } else {
                    AddMoreTagView()
                        .padding(.leading, 1)
                        .onTapGesture {
                            isEditing = true
                        }
                }
            }
            .frame(width: tagsListSubviewSize)
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getIndex(tag: Tag) -> Int {
        let index = tags.firstIndex { currentTag in
            return tag.id == currentTag.id
        } ?? 0
        return index
    }
    
    private func getRows() -> [[Tag]] {
        var rows: [[Tag]] = []
        var currentRow: [Tag] = []
        var totalWidth: CGFloat = 0
        let screenWidth: CGFloat = tagsListSubviewSize + 10
        tags.forEach { tag in
            totalWidth += tag.size
            
            if totalWidth > screenWidth {
                totalWidth = 0
                
                rows.append(currentRow)
                currentRow.removeAll()
                currentRow.append(tag)
            } else {
                currentRow.append(tag)
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
            currentRow.removeAll()
        }
        
        return rows
    }
}

struct TechniquesListView_Previews: PreviewProvider {
    struct Container: View {
        
        var body: some View {
            TechniquesListView()
        }
    }
    
    static var previews: some View {
        Container()
    }
}
