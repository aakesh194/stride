//
//  ContentView.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/19/26.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = DashboardViewModel()
    ///
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "heart.fill") {
                DashboardView(vm: vm)
            }
            Tab("Insights", systemImage: "brain.head.profile") {
                InsightView()
            }
        }
    }
}

#Preview {
    ContentView()
}
