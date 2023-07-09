//
//  String+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.05.2023.
//

import Foundation
import UIKit

extension String {
    var localizedString: String {
        String(format: NSLocalizedString(self, comment: ""))
    }
    
    func localized(with arguments: [CVarArg]) -> String {
        return String(format: NSLocalizedString(self, comment: ""), locale: nil, arguments: arguments)
    }
    
    func textSize(_ font: UIFont = UIFont.systemFont(ofSize: 14)) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: attributes)
    }
}
