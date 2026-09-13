//
//  InsightViewModel.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/20/26.
//


import Foundation
import Observation

@Observable
class InsightViewModel {

    var insight: String = ""
    var isLoading: Bool = false

    private let service = InsightService(
        apiKey: Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
    )
//    init() {
//        let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
//        self.service = InsightService(apiKey: key)
//    }
    
    func loadInsight() async {
        isLoading = true
        defer { isLoading = false }

        do {
            //let snapshot = try await HealthKitManager.shared.fetchTodaySnapshot()
            let snapshots = try await HealthKitManager.shared.fetchLast7DaySnapshots()
            
//            insight = try await service.generateInsight(
//                mobility: snapshot
            insight = try await service.generateInsight(snapshots: snapshots)
            
        } catch {
            insight = "Failed to generate insight."
        }
    }
}
