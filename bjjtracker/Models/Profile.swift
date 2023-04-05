//
//  Profile.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation

enum Belt {
    case white
    case blue
    case purple
    case brown
    case black
}

struct Profile {
    var belt: Belt
    var stripes: Int?
}
