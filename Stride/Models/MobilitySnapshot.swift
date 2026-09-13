//
//  MobilitySnapshot.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/19/26.
//

import HealthKit
import Combine
import Foundation

struct MobilitySnapshot: Codable {
    var walkingSpeed: Double?          // m/s
    var stepLength: Double?            // meters
    var doubleSupportPercent: Double?  // %
    var asymmetryPercent: Double?      // %
    var steadinessScore: SteadinessLevel?       // 0.0 – 1.0
    var stepCount: Double?
    var date: Date
}

enum SteadinessLevel: Codable {
    case ok
    case low
    case veryLow
    case noData
}
