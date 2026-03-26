//
//  AppReview.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation
import UIKit
import StoreKit

@MainActor
protocol AppReviewProtocol {
    func promptAppReview()
}

final class AppReview: AppReviewProtocol {
    
    func promptAppReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })
            as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
    
}
