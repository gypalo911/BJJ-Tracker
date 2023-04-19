//
//  NewSessionPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct NewSessionPresenter {
    private let storageService: ActivitiesStoraging = CoreDataService()
    
    @State var activity: Activity = .init(type: .session, style: .gi, duration: 0, startDate: Date(), location: "", notes: "")
    var isEditing: Bool
    
    
}
