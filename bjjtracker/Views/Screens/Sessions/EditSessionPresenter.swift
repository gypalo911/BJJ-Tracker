//
//  EditSessionPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

class EditSessionPresenter: ObservableObject {
    private let storageService: ActivitiesStoraging & ActivitiesReading = CoreDataService()
    
    @Published var activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    func update() {
        do {
            try storageService.update(activity)
        } catch let error {
            print(error)
        }
    }
}
