//
//  ActivitiesManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation

protocol StatsCalculation {
    func totalTime(dateInterval: DateInterval) -> String
}

protocol ActivitiesFetching {
    func activity(by id: UUID) -> Activity?
    func allActivities() -> [Activity]
    func activities(for dateInterval: DateInterval) -> [Activity]
    func activities(by type: ActivityType, dateInterval: DateInterval) -> [Activity]
    func activities(by style: GraplingStyle, dateInterval: DateInterval) -> [Activity]
}

protocol ActivitiesEditing {
    func save(_ activity: Activity)
    func update(_ activity: Activity)
    func deleteActivity(with id: UUID)
}

class ActivitiesManager: ObservableObject, ActivitiesFetching {
    
    typealias Service = ActivitiesStoraging & ActivitiesReading
    
    private var storageService: Service
    
    @Published var groupedActivities: Dictionary<Date, [Activity]> = [:]
    
    init(storageService: Service) {
        self.storageService = storageService
        
        self.groupedActivities = Dictionary(grouping: allActivities(), by: {
            Calendar.current.startOfDay(for: $0.startDate)
        })
    }
    
    func allActivities() -> [Activity] {
        do {
            return try storageService.fetchAllActivities()
        } catch let error {
            print("allActivities error: \(error)")
            return []
        }
    }
    
    func activities(for dateInterval: DateInterval) -> [Activity] {
        do {
            return try storageService.fetchActivities(from: dateInterval)
        } catch let error {
            print("activities(for dateInterval error: \(error)")
            return []
        }
    }
    
    func activity(by id: UUID) -> Activity? {
        do {
            return try storageService.fetchActivity(by: id)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func activities(by type: ActivityType, dateInterval: DateInterval) -> [Activity] {
        return activities(for: dateInterval).filter({ $0.type == type })
    }
    
    func activities(by style: GraplingStyle, dateInterval: DateInterval) -> [Activity] {
        return activities(for: dateInterval).filter({ $0.style == style })
    }
}

extension ActivitiesManager: ActivitiesEditing {
    func save(_ activity: Activity) {
        do {
            try storageService.save(activity)
        } catch let error {
            print(error)
        }
    }
    
    func deleteActivity(with id: UUID) {
        do {
            try storageService.deleteActivity(with: id)
        } catch let error {
            print(error)
        }
    }
    
    func update(_ activity: Activity) {
        do {
            try storageService.update(activity)
        } catch let error {
            print(error)
        }
    }
}

extension ActivitiesManager: StatsCalculation {
    func totalTime(dateInterval: DateInterval) -> String {
        return activities(for: dateInterval).map { $0.duration }.reduce(0, +).minutesToDuration()
    }
}
