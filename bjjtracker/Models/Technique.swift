//
//  Technique.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 23.08.2023.
//

import Foundation

class Technique: Identifiable, ObservableObject {
    var id = UUID()
    
    var name: String
    var details: String
    
    init(name: String, details: String) {
        self.name = name
        self.details = details
    }
}

struct Tag: Identifiable, Hashable {
    enum TagType: String {
        case regular
        case suggestion
    }
    
    var technique: TechniqueModel? = nil
    
    var id: String =  UUID().uuidString
    var text: String
    var size: CGFloat = 0
    var type: TagType = .regular
}
