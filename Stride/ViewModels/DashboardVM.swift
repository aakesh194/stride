//
//  DashboardVM.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/19/26.
//

import Combine
import Foundation
import Observation

@Observable
class DashboardViewModel {
    var report: MobilitySnapshot = .init(date: Date())
    var isLoading: Bool = false
    var errorMessage: String?
    var isAuthorized: Bool = false
    var weeklySnapshots: [MobilitySnapshot] = []

    private let manager: HealthKitManager

    init(manager: HealthKitManager = .shared) {
        self.manager = manager

        Task {
            await requestAuthorization()
        }
    }

    func requestAuthorization() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let success = try await manager.requestAuthorization()
            isAuthorized = success

            if success {
                report = try await manager.fetchTodaySnapshot()
                weeklySnapshots = try await manager.fetchLast7DaySnapshots()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

//    func load() async {
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            let success = try await manager.requestAuthorization()
//            isAuthorized = success
//
//            guard success else { return }
//
//            report = try await manager.fetchTodaySnapshot()
//
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }

    // this is the string formats for all the values for the dashboard cards

    var formattedSpeed: String {
        guard let s = report.walkingSpeed else { return "—" }
        return String(format: "%.2f m/s", s)
    }

    var formattedStepLength: String {
        guard let l = report.stepLength else { return "—" }
        return String(format: "%.0f cm", l * 100)
    }

    var formattedDoubleSupport: String {
        guard let d = report.doubleSupportPercent else { return "—" }
        return String(format: "%.1f%%", d * 100)
    }

    var formattedAsymmetry: String {
        guard let a = report.asymmetryPercent else { return "—" }
        return String(format: "%.1f%%", a * 100)
    }

    var formattedSteadiness: String {
//        guard let s = report.steadinessScore else { return "—" }
//        return String(format: "%.0f%%", s * 100)
        switch report.steadinessScore {
        case .ok:
            return "OK 🟢"
        case .low:
            return "Low 🟡"
        case .veryLow:
            return "Very Low 🔴"
        case .noData:
            return "-"
        @unknown default:
            return "-"
        }
    }

    var formattedSteps: String {
        guard let s = report.stepCount else { return "—" }
        return "\(Int(s))"
    }

}
