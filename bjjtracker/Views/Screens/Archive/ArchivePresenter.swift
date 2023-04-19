//
//  ArchivePresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

class ArchivePresenter: ObservableObject {
    var manager: ActivitiesManager = ActivitiesManager(storageService: CoreDataService())
    
    @Published var groupedItems: Dictionary<Date, [Activity]>
    
    init() {
        self.groupedItems = Dictionary(grouping: manager.allActivities(), by: {
            Calendar.current.startOfDay(for: $0.startDate)
        })
    }
    
    func fetchItems() {
        self.groupedItems = Dictionary(grouping: manager.allActivities(), by: {
            Calendar.current.startOfDay(for: $0.startDate)
        })
    }
}
