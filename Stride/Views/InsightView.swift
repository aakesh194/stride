//
//  InsightView.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/20/26.
//


import SwiftUI

struct InsightView: View {

    @State private var vm = InsightViewModel()

//    let speed: String
//    let stepLength: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            VStack (alignment: .leading){
                Text("Mobility Report")
                    .font(.largeTitle.bold())
            }

            if vm.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Text("Generating Insight...")
                        .font(.subheadline).bold()
                    Spacer()
                }
            } else {
                Text(vm.insight)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            HStack {
                Spacer()
                Button("Generate AI Insight") {
                    Task {
                        //let test = MobilitySnapshot(date: Date())
                        await vm.loadInsight()
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline).bold()
                //frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @State var vm = InsightViewModel()
    InsightView()
}
