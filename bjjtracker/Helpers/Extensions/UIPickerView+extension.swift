//
//  UIPickerView+extension.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.08.2023.
//

import UIKit

extension UIPickerView {
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 150)
    }
}
