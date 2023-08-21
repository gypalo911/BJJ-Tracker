//
//  HealthKitService.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 15.08.2023..
//

import Foundation
import HealthKit

protocol HealthKitService {
    var isDataAuthorized: Bool { get }
    var isMetricSystem: Bool { get }
    func authorizeHealthKitIfNeeded(
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func authorizationRequestStatus(
        completion: @escaping (Result<HKAuthorizationRequestStatus, Error>) -> Void
    )
    
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus
    func workoutsCount(dateInterval: DateInterval) async -> Int
    func energyStatisticsValue(
        dateInterval: DateInterval,
        calculation: HealthKitServiceCalculationType
    ) async -> Double
    func store(session: Session)
}

enum HealthKitServiceError: Error {
    case healthDataUnavalable
    case dataTypeUnavailable(String)
    case permissionsAlreadyGranted
    case invalidDateInterval
}

extension HealthKitServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .healthDataUnavalable:
            return ""//L10n.OneApp.AppleHealth.Error.healthUnavailable
            
        case .dataTypeUnavailable(let type):
            return ""//L10n.OneApp.AppleHealth.Error.dataTypeUnavailable(type)
            
        case .permissionsAlreadyGranted:
            return ""//L10n.OneApp.AppleHealth.Error.permissionsAlreadyGranted
        case .invalidDateInterval:
            return ""//L10n.OneApp.AppleHealth.Error.invalidDateInterval
        }
    }
}

enum HealthKitServiceCalculationType {
    case sum
    case average
    case max
    case min
    case latest
    
    var statisticsOptions: HKStatisticsOptions {
        switch self {
        case .sum:
            return .cumulativeSum
        case .average:
            return .discreteAverage
        case .max:
            return .discreteMax
        case .min:
            return .discreteMin
        case .latest:
            return .mostRecent
        }
    }
    
    var stringValue: String {
        switch self {
        case .sum:
            return "Total"
        case .average:
            return "Daily average"
        case .max:
            return "Max"
        case .min:
            return "Min"
        case .latest:
            return "Latest"
        }
    }
}

final class DefaultHealthKitService: ObservableObject, HealthKitService {
    
    private let healthStore = HKHealthStore()
    
    var isDataAuthorized: Bool {
        let statuses = readTypes.map {
            authorizationStatus(for: $0)
        }
        return statuses.contains(.sharingAuthorized) || !statuses.contains(.notDetermined)
    }
    
    var isMetricSystem: Bool {
        return Locale.current.usesMetricSystem
    }
    
    private let writeTypes: Set<HKSampleType> = Set(
        [
            HKSampleType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
        ].compactMap { $0 }
    )
    
    private let readTypes: Set<HKObjectType> = Set(
        [
            HKObjectType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
        ].compactMap{ $0 }
    )
    
    func authorizeHealthKitIfNeeded(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        authorizationRequestStatus { result in
            switch result {
            case .success(let status):
                if status == .shouldRequest {
                    self.authorizeHealthKit(completion: completion)
                } else {
                    completion(.failure(HealthKitServiceError.permissionsAlreadyGranted))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func authorizationRequestStatus(
        completion: @escaping (Result<HKAuthorizationRequestStatus, Error>) -> Void
    ) {
        healthStore.getRequestStatusForAuthorization(
            toShare: writeTypes,
            read: readTypes
        ) { status, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(status))
            }
        }
    }
    
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: type)
    }
    
    private func authorizeHealthKit(
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(HealthKitServiceError.healthDataUnavalable))
            return
        }
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}

// MARK: - Fetching and Storing data

extension DefaultHealthKitService {
    func store(session: Session) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = HKWorkoutActivityType.martialArts
        configuration.locationType = .indoor
        let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: configuration,
                                       device: .local())
        
        guard let start = session.startDate else {
            return
        }
        let end = start + TimeInterval(session.duration * 60)
        
        builder.beginCollection(withStart: start) { (success, error) in
            guard success else {
                return
            }
            
            guard let quantityType = HKQuantityType.quantityType(
                forIdentifier: .activeEnergyBurned) else {
                return
            }
            
            let unit = HKUnit.kilocalorie()
            let totalEnergyBurned = Double(session.duration) / 60 * 600
            let quantity = HKQuantity(
                unit: unit,
                doubleValue: totalEnergyBurned
            )
            let sample = HKCumulativeQuantitySample(
                type: quantityType,
                quantity: quantity,
                start: start,
                end: end
            )
            //1. Add the sample to the workout builder
            builder.add([sample]) { (success, error) in
                guard success else {
                    return
                }
                builder.addMetadata(["sessionId": session.id]) { _, _ in }
                
                //2. Finish collection workout data and set the workout end date
                builder.endCollection(withEnd: end) { (success, error) in
                    guard success else {
                        print("error durting storing activity")
                        return
                    }
                    
                    //3. Create the workout with the samples added
                    builder.finishWorkout { (_, error) in
                        //                  let success = error == nil
                        //                  completion(success, error)
                        print("successfully stored activity")
                    }
                }
            }
            
        }
    }
    
    func delete(session: Session) {
        var healthDataSession: HKObject?
        fetchData(by: session.id!) { data, _ in
            healthDataSession = data
        }
        if let healthDataSession = healthDataSession {
            healthStore.delete(healthDataSession) { _, _ in }
        }
    }
    
    func fetchData(by sessionId: UUID, completion: @escaping (HKWorkout, Error?) -> Void) {
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .martialArts)
//        let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        let metadataPredicate = HKQuery.predicateForObjects(withMetadataKey: "sessionId")
        
        //3. Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
                                            [])
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compound,
            limit: 0,
            sortDescriptors: []
        ) { (query, samples, error) in
            DispatchQueue.main.async {
                guard
                    let samples = samples as? [HKWorkout],
                    error == nil
                else {
//                    completion(nil, error)
                    return
                }
                
                print(samples)
                if let sample = samples.first {
                    completion(sample, nil)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func statisticsValue<T: HKQuantityType>(
        quantityType: T,
        dateInterval: DateInterval,
        calculation: HealthKitServiceCalculationType,
        unit: HKUnit,
        completion: @escaping (Result<Double?, Error>) -> Void
    ) {
        let predicate = HKQuery.predicateForSamples(
            withStart: dateInterval.start,
            end: dateInterval.end,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: calculation.statisticsOptions
        ) { query, results, error in
            if let error = error {
                completion(.failure(error))
            } else if let results = results {
                let value: Double?
                switch calculation {
                case .sum:
                    value = results.sumQuantity()?.doubleValue(for: unit)
                case .average:
                    value = results.averageQuantity()?.doubleValue(for: unit)
                case .max:
                    value = results.maximumQuantity()?.doubleValue(for: unit)
                case .min:
                    value = results.minimumQuantity()?.doubleValue(for: unit)
                case .latest:
                    value = results.mostRecentQuantity()?.doubleValue(for: unit)
                }
                
                completion(.success(value))
            }
        }
        healthStore.execute(query)
    }
    
    func workoutsCount(dateInterval: DateInterval) async -> Int {
        return await withCheckedContinuation { continuation in
            let metadataPredicate = HKQuery.predicateForObjects(withMetadataKey: "sessionId")
            let predicate = HKQuery.predicateForSamples(
                withStart: dateInterval.start,
                end: dateInterval.end,
                options: .strictStartDate
            )
            
            let query = HKSampleQuery(sampleType: HKSampleType.workoutType(), predicate: predicate, limit: 60, sortDescriptors: [])
            { query, results, error in
                if error != nil {
                    continuation.resume(returning: 0)
                } else if let results = results {
                    continuation.resume(returning: results.count)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func statisticAverageValue(
        quantityType: HKQuantityType?,
        dateInterval: DateInterval,
        calculation: HealthKitServiceCalculationType,
        unit: HKUnit
    ) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            guard let quantityType = quantityType else {
                continuation.resume(throwing: HealthKitServiceError.dataTypeUnavailable(""))
                return
            }
            let predicate = HKQuery.predicateForSamples(
                withStart: dateInterval.start,
                end: dateInterval.end,
                options: .strictStartDate
            )
            var interval = DateComponents()
            interval.day = 1
            
            guard let anchorDate = Calendar.current.nextDate(
                after: dateInterval.end,
                matching: interval,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) else {
                continuation.resume(returning: 0)
                return
            }
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = {
                query, results, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let statsCollection = results else {
                    continuation.resume(returning: 0)
                    return
                }
                
                var checkedDays: Set<Date> = []
                var totalSum: Double = 0
                
                statsCollection.enumerateStatistics(from: dateInterval.start, to: dateInterval.end)
                { (statistics, stop) in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.endDate
                        let value = quantity.doubleValue(for: unit)
                        
                        totalSum += value
                        checkedDays.insert(date)
                    }
                }
                if !checkedDays.isEmpty {
                    continuation.resume(returning: totalSum)
                } else {
                    continuation.resume(returning: 0)
                }
            }
            healthStore.execute(query)
        }
    }
    
    func energyStatisticsValue(
        dateInterval: DateInterval,
        calculation: HealthKitServiceCalculationType
    ) async -> Double {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)
        else {
            return 0
        }
        return await withTaskGroup(of: Double.self, returning: Double.self) { group in
            var totalEnergy: Double = 0
            for energyType in [activeEnergyType, basalEnergyType] {
                group.addTask { [self] in
                    do {
                        return try await statisticAverageValue(
                            quantityType: energyType,
                            dateInterval: dateInterval,
                            calculation: calculation,
                            unit: .kilocalorie()
                        )
                    } catch {
                        return (0)
                    }
                }
            }
            
            for await energy in group {
                totalEnergy += energy
            }
            return totalEnergy
        }
    }
}
