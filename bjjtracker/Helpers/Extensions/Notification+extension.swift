//
//  Notification+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 11.07.2023.
//

import UIKit

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
