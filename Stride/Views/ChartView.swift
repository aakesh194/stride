//
//  ChartView.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/20/26.
//

import SwiftUI
import Charts

struct StepsChartView: View {
    let data: [MobilitySnapshot]

    var body: some View {
        Chart(data, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date, unit: .day),
                y: .value("Steps", item.stepCount ?? 0)
            )
        }
        .padding()
        .navigationTitle("Weekly Steps")
    }
}

struct SpeedChartView: View {
    let data: [MobilitySnapshot]

    var body: some View {
        Chart(data, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date, unit: .day),
                y: .value("Speed", item.walkingSpeed ?? 0)
            )
        }
        .padding()
        .navigationTitle("Weekly Speed")
    }
}

struct LengthChartView: View {
    let data: [MobilitySnapshot]

    var body: some View {
        Chart(data, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date, unit: .day),
                y: .value("Step Length", (item.stepLength ?? 0) * 100)
            )
        }
        .padding()
        .navigationTitle("Weekly Step Length")
    }
}

struct DSChartView: View {
    let data: [MobilitySnapshot]

    var body: some View {
        Chart(data, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date, unit: .day),
                y: .value("Double Support", (item.doubleSupportPercent ?? 0) * 100)
            )
        }
        .padding()
        .navigationTitle("Weekly Double Support")
    }
}

struct AsymChartView: View {
    let data: [MobilitySnapshot]

    var body: some View {
        Chart(data, id: \.date) { item in
            BarMark(
                x: .value("Day", item.date, unit: .day),
                y: .value("Asymmetry", (item.asymmetryPercent ?? 0) * 100)
            )
        }
        .padding()
        .navigationTitle("Weekly Asymmetry")
    }
}

//#Preview {
//    ChartView()
//}
