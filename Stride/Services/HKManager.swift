//
//  HKManager.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/19/26.
//

import Combine
import Foundation
import HealthKit
import Observation

// HealthKit Manager

@Observable
class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private init() {}
    
    func requestAuthorization() async throws -> Bool {
        // checking if HealthKit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else { return false }
        
        // define the types we want to read
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.walkingSpeed),
            HKQuantityType(.walkingStepLength),
            HKQuantityType(.walkingDoubleSupportPercentage),
            HKQuantityType(.walkingAsymmetryPercentage),
            HKQuantityType(.appleWalkingSteadiness),
            HKQuantityType(.stepCount)
        ]
        
        // bridge callback
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    // MARK: - Today snapshot
    
    func fetchTodaySnapshot() async throws -> MobilitySnapshot {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Date()
        return try await fetchSnapshot(start: start, end: end)
    }
    
    func fetchWeekSnapshot() async throws -> MobilitySnapshot {
        let start = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        let end = Date()
        
        return try await fetchSnapshot(start: start, end: end)
    }
    
    func fetchLast7DaySnapshots() async throws -> [MobilitySnapshot] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var snapshots: [MobilitySnapshot] = []

        for offset in (0..<7).reversed() {

            guard
                let start = calendar.date(byAdding: .day, value: -offset, to: today),
                let end = calendar.date(byAdding: .day, value: 1, to: start)
            else { continue }

            let snapshot = try await fetchSnapshot(start: start, end: end)
            snapshots.append(snapshot)
        }
        return snapshots
    }
    
    func fetchSnapshot(start: Date, end: Date) async throws -> MobilitySnapshot {
        //        let start = Calendar.current.startOfDay(for: Date())
        //        let start = Calendar.current.startOfDay(
        //            for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        // let start = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        //let end = Date()
        
        // all queries other than steadiness
        func statsQuery(
            _ id: HKQuantityTypeIdentifier,
            options: HKStatisticsOptions,
            unit: HKUnit
        ) async -> Double? {
            await withCheckedContinuation { continuation in
                guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
                
                let query = HKStatisticsQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: options
                ) { _, result, _ in
                    let value: Double?
                    
                    switch options {
                    case .cumulativeSum:
                        value = result?.sumQuantity()?.doubleValue(for: unit)
                    case .discreteAverage:
                        value = result?.averageQuantity()?.doubleValue(for: unit)
                    default:
                        value = nil
                    }
                    
                    continuation.resume(returning: value)
                }
                
                self.healthStore.execute(query)
            }
        }
        
        // steadiness query
        //        func steadQuery() async -> HKAppleWalkingSteadinessClassification {
        //            await withCheckedContinuation { continuation in
        //                guard let type = HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness) else {
        //                    continuation.resume(returning: .low)
        //                    return
        //                }
        //
        //                let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        //
        //                let query = HKSampleQuery(
        //                    sampleType: type,
        //                    predicate: predicate,
        //                    limit: 1,
        //                    sortDescriptors: [
        //                        NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        //                    ]
        //                ) { _, samples, _ in
        //                    guard
        //                        let sample = samples?.first as? HKQuantitySample
        //                    else {
        //                        continuation.resume(returning: .low)
        //                        return
        //                    }
        //
        //                    let classification = (try? HKAppleWalkingSteadinessClassification(
        //                        for: sample.quantity
        //                    )) ?? .low
        //
        //                    continuation.resume(returning: classification)
        //                }
        //
        //                self.healthStore.execute(query)
        //            }
        //        }
        func steadQuery() async -> SteadinessLevel {
            await withCheckedContinuation { continuation in
                guard let type = HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness) else {
                    continuation.resume(returning: .noData)
                    return
                }
                
                let predicate = HKQuery.predicateForSamples(
                    withStart: .distantPast,
                    end: Date()
                )
                
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: [
                        NSSortDescriptor(
                            key: HKSampleSortIdentifierEndDate,
                            ascending: false
                        )
                    ]
                ) { _, samples, _ in
                    guard
                        let quantitySample = samples?.first as? HKQuantitySample
                    else {
                        continuation.resume(returning: .noData)
                        return
                    }
                    
                    do {
                        let classification = try HKAppleWalkingSteadinessClassification(
                            for: quantitySample.quantity
                        )
                        // converting HKAppleWalkingSteadinessClassification into our SteadinessLevel
                        let level: SteadinessLevel
                        
                        switch classification {
                        case .ok:
                            level = .ok
                        case .low:
                            level = .low
                        case .veryLow:
                            level = .veryLow
                        @unknown default:
                            fatalError()
                        }
                        continuation.resume(returning: level)
                    } catch {
                        continuation.resume(returning: .noData)
                    }
                }
                
                self.healthStore.execute(query)
            }
        }
        
        async let steps = statsQuery(.stepCount, options: .cumulativeSum, unit: .count())
        async let speed = statsQuery(.walkingSpeed, options: .discreteAverage,
                                     unit: HKUnit.meter().unitDivided(by: .second()))
        async let length = statsQuery(.walkingStepLength, options: .discreteAverage, unit: .meter())
        async let support = statsQuery(.walkingDoubleSupportPercentage, options: .discreteAverage, unit: .percent())
        async let asymmetry = statsQuery(.walkingAsymmetryPercentage, options: .discreteAverage, unit: .percent())
        async let steadiness = steadQuery()
        
        return await MobilitySnapshot(
            walkingSpeed: speed,
            stepLength: length,
            doubleSupportPercent: support,
            asymmetryPercent: asymmetry,
            steadinessScore: steadiness,
            stepCount: steps,
            date: start
        )
    }
    
    
    // time series for chart; this uses HKStatisticsCollectionQuery
    
    
    func fetchSteps(from startDate: Date, to endDate: Date) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, results, error in
            results?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                let steps = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                print("Hour starting at \(stats.startDate): \(steps) steps")
            }
        }
        
        HKHealthStore().execute(query)
    }
    
    func fetchSeries(
        type: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions,
        startDate: Date,
        endDate: Date,
        interval: DateComponents
    ) async throws -> [(Date, Double)] {
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else {
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: nil,
                options: options,
                anchorDate: Calendar.current.startOfDay(for: startDate),
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                var output: [(Date, Double)] = []
                
                results?.enumerateStatistics(from: startDate, to: endDate) { stats, _ in
                    
                    let value: Double
                    
                    switch options {
                    case .cumulativeSum:
                        value = stats.sumQuantity()?.doubleValue(for: unit) ?? 0
                        
                    case .discreteAverage:
                        value = stats.averageQuantity()?.doubleValue(for: unit) ?? 0
                        
                    default:
                        value = 0
                    }
                    
                    output.append((stats.startDate, value))
                }
                
                continuation.resume(returning: output)
            }
            
            HKHealthStore().execute(query)
        }
    }
    
    
    
    //    func fetchTodaySnapshot() async throws -> MobilitySnapshot {
    //        let start = Calendar.current.startOfDay(for: Date())
    //        let end = Date()
    //
    //        async let steps = fetchSum(.stepCount, unit: .count(), start: start, end: end)
    //
    //        async let speed = fetchAverage(.walkingSpeed, unit: HKUnit.meter().unitDivided(by: .second()), start: start, end: end)
    //
    //        async let length = fetchAverage(.walkingStepLength, unit: .meter(), start: start, end: end)
    //
    //        async let support = fetchAverage(.walkingDoubleSupportPercentage, unit: .percent(), start: start, end: end)
    //
    //        async let asymmetry = fetchAverage(.walkingAsymmetryPercentage, unit: .percent(), start: start, end: end)
    //
    //        async let steadiness = fetchAverage(.appleWalkingSteadiness, unit: .percent(), start: start, end: end)
    //
    //        return try await MobilitySnapshot(
    //            walkingSpeed: speed,
    //            stepLength: length,
    //            doubleSupportPercent: support,
    //            asymmetryPercent: asymmetry,
    //            steadinessScore: steadiness,
    //            stepCount: steps,
    //            date: Date()
    //        )
    //    }
    
    //    func fetchTodaySnapshot() -> MobilitySnapshot {
    //        // get the quantity type for the identifier
    //        guard let quantityType = HKObjectType.quantityType(forIdentifier: id) else {
    //            return nil
    //        }
    //
    //        // expanding steps to all types in MobilitySnapshot
    //        let start = Calendar.current.startOfDay(for: Date())
    //        let end = Date()
    //
    //        async let speed = fetchAverage(.walkingSpeed, unit: HKUnit.meter().unitDivided(by: .second()), start: start, end: end)
    //        async let length = fetchAverage(.walkingStepLength, unit: .meter(), start: start, end: end)
    //        async let support = fetchAverage(.walkingDoubleSupportPercentage, unit: .percent(), start: start, end: end)
    //        async let asymmetry = fetchAverage(.walkingAsymmetryPercentage, unit: .percent(), start: start, end: end)
    //        async let steadiness = fetchAverage(.appleWalkingSteadiness, unit: .percent(), start: start, end: end)
    //        async let steps = fetchSum(.stepCount, unit: .count(), start: start, end: end)
    //
    //
    //        // query for samples from start of today until now, sorted by end date descending
    //        let predicate = HKQuery.predicateForSamples(
    //            withStart: Calendar.current.startOfDay(for: Date()),
    //            end: Date(),
    //            options: .strictStartDate
    //        )
    //        let sortDescriptor = NSSortDescriptor(
    //            key: HKSampleSortIdentifierEndDate,
    //            ascending: false
    //        )
    //
    //        return try await withCheckedThrowingContinuation { continuation in
    //            let query = HKSampleQuery(
    //                sampleType: quantityType,
    //                predicate: predicate,
    //                limit: 1,
    //                sortDescriptors: [sortDescriptor]
    //            ) { _, samples, error in
    //                if let error = error {
    //                    continuation.resume(throwing: error)
    //                } else {
    //                    continuation.resume(returning: samples?.first as? HKQuantitySample)
    //                }
    //            }
    //            healthStore.execute(query)
    //        }
    //    }
    
    //    func fetchTodaySnapshot(id: HKQuantityTypeIdentifier) async throws -> Double? {
    //        // expanding steps to all types in MobilitySnapshot
    //
    //        // let type = HKQuantityType(.stepCount)
    //        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return nil }
    //
    //        let start = Calendar.current.startOfDay(for: Date())
    //        let end = Date()
    //
    //        return try await withCheckedThrowingContinuation { continuation in
    //            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
    //
    //            let query = HKStatisticsQuery(
    //                quantityType: type,
    //                quantitySamplePredicate: predicate,
    //                options: .cumulativeSum
    //            ) { _, result, error in
    //                if let error = error {
    //                    continuation.resume(throwing: error)
    //                    return
    //                }
    //
    //                let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    //                continuation.resume(returning: count)
    //            }
    //
    //            self.healthStore.execute(query)
    //        }
    //    }
    
    //    func fetchToday() async -> MobilitySnapshot {
    //
    //    }
    //    func fetchTodaySnapshot() async -> MobilitySnapshot {
    //        let start = Calendar.current.startOfDay(for: Date())
    //        let end = Date()
    //
    //        async let speed = fetchAverage(.walkingSpeed, unit: HKUnit.meter().unitDivided(by: .second()), start: start, end: end)
    //        async let length = fetchAverage(.walkingStepLength, unit: .meter(), start: start, end: end)
    //        async let support = fetchAverage(.walkingDoubleSupportPercentage, unit: .percent(), start: start, end: end)
    //        async let asymmetry = fetchAverage(.walkingAsymmetryPercentage, unit: .percent(), start: start, end: end)
    //        async let steadiness = fetchAverage(.appleWalkingSteadiness, unit: .percent(), start: start, end: end)
    //        async let steps = fetchSum(.stepCount, unit: .count(), start: start, end: end)
    //
    //        return MobilitySnapshot(
    //            walkingSpeed: await speed,
    //            stepLength: await length,
    //            doubleSupportPercent: await support.map { $0 * 100 },
    //            asymmetryPercent: await asymmetry.map { $0 * 100 },
    //            steadinessScore: await steadiness,
    //            stepCount: await steps,
    //            date: Date()
    //        )
    //    }
    //
}
