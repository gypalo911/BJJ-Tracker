//
//  ActivitiesManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation

protocol StatsCalculation {
    func totalTime() -> Int
    func totalSessions() -> Int
}

protocol ActivitiesFetching {
    func activity(by id: UUID) -> Activity?
    func activities(from dateInterval: DateInterval) -> [Activity]
}

struct ActivitiesManager: StatsCalculation, ActivitiesFetching {
    private var storageService: ActivitiesStoraging & ActivitiesReading
    
    func totalTime() -> Int {
        do {
            return try storageService.fetchAllActivities().map({ $0.duration }).reduce(0, +)
        } catch let error {
            print(error)
            return 0
        }
    }
    
    func totalSessions() -> Int {
        do {
            return try storageService.fetchAllActivities().count
        } catch let error {
            print(error)
            return 0
        }
    }
    
    func activities(from dateInterval: DateInterval) -> [Activity] {
        do {
            return try storageService.fetchActivities(from: dateInterval)
        } catch let error {
            print(error)
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
    
    func deleteActivity(with id: UUID) {
        do {
            try storageService.deleteActivity(with: id)
        } catch let error {
            print(error)
        }
    }
}
