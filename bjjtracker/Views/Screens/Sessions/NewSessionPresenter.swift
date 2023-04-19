//
//  NewSessionPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

class NewSessionPresenter: ObservableObject {
    private let storageService: ActivitiesStoraging & ActivitiesReading = CoreDataService()
    
    @Published var activity: Activity
    @Published var isEditing: Bool
    
    init(
        activity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "", notes: ""),
        isEditing: Bool
    ) {
        self.activity = activity
        self.isEditing = isEditing
    }
    
    func save() {
        do {
            try storageService.save(activity)
        } catch let error {
            print(error)
        }
    }
    
    func update() {
        do {
            try storageService.update(activity)
        } catch let error {
            print(error)
        }
    }
}
