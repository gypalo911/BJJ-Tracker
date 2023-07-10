//
//  TechniquesListViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.07.2023.
//

import Foundation

class ContentViewModel: ObservableObject{
    
    @Published var rows: [[Tag]] = []
    @Published var tags: [Tag] = [
//        .init(text: "Delariva"),
//        .init(text: "Spyder Guard"),
//        .init(text: "Delariva")
    ]
    @Published var tagText = ""
    
    var maxRowWidth: CGFloat = 0
    
    func add(tag: Tag) {
        if !tag.text.trimmingCharacters(in: .whitespaces).isEmpty {
            tags.append(tag)
            getTags()
        }
    }
    
    func removeTag(by id: String){
        tags = tags.filter{ $0.id != id }
        getTags()
    }
    
    func getIndex(tag: Tag) -> Int {
        let index = tags.firstIndex { currentTag in
            return tag.id == currentTag.id
        } ?? 0
        return index
    }
    
    func getTags() {
        var rows: [[Tag]] = []
        var currentRow: [Tag] = []
        var totalWidth: CGFloat = 0
        let tagSpacing: CGFloat = 20 /*Leading & Trailing 10, 10 Spacing*/
        
        if !tags.isEmpty{
            for index in 0..<tags.count{
                self.tags[index].size = tags[index].text.textSize().width + 25
            }
            
            tags.forEach { tag in
                totalWidth += (tag.size + tagSpacing)
                
                if totalWidth > self.maxRowWidth {
                    totalWidth = !currentRow.isEmpty ? (tag.size + 40) : 0
                    
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
            
            self.rows = rows
        } else {
            self.rows = []
        }
        
        
    }
}
