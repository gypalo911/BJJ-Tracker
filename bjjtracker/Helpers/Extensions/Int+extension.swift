//
//  Int+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 25.05.2023.
//

import Foundation

extension Int {
    func minutesToDuration() -> String {
        var str = ""
        let hours = Int(self / 60)
        let minutes = Int(self % 60)
        
        if hours != 0 && minutes != 0 {
            str = "%@h %@m".localized(with: ["\(hours)", "\(minutes)"])
        } else if hours != 0 && minutes == 0 {
            str = "%@h".localized(with: ["\(hours)"])
        } else {
            str = "%@min".localized(with: ["\(minutes)"])
        }
        
        return str
    }
}

protocol StringComparable {
    var stringValue: String { get set }
}

extension Int: StringComparable {
    var stringValue: String {
        get {
            return String(self)
        }
        set {}
    }
}
