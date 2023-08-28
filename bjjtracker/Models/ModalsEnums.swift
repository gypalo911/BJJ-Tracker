//
//  ModalsEnums.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation

enum ModalSheets: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case activity
    case promotion
}

enum BottomSheets: Int, Identifiable {
    var id: Int { self.rawValue }
    
    case techniqueDetails
    case techniqueModification
}
