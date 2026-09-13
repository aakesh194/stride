//
//  DashboardView.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/19/26.
//

import Charts
import SwiftUI

struct DashboardView: View {
    @Bindable var vm: DashboardViewModel
    
    var body: some View {
        // VStack(alignment: .leading) {
        // debugging
        //            ForEach(vm.weeklySnapshots, id: \.date) { item in
        //                Text("\(item.date): \(item.stepCount ?? 0)")
        //            }
        // }
        // should probably make all the card views a ForEach struct later

        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Stride")
                        .font(.largeTitle).bold()
                        .font(.system(size: 100))
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date(), style: .date)
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.secondary)
                            Text("Mobility Report")
                                .font(.title2)
                        }
                        Spacer()
                        Image(systemName: "figure.walk.circle.fill")
                            .font(.system(size: 50))
                            // .foregroundStyle(.blue)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.variableColor, options: .repeating.speed(0.5))
                        // .symbolEffect(.variableColor, options: .repeating)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
                    
                // step card
                // NavigationStack {
                VStack {
                    HStack {
                        NavigationLink {
                            //                            Chart(vm.weeklySnapshots, id: \.date) { item in
                            //                                BarMark(
                            //                                    x: .value("Day", item.date, unit: .day),
                            //                                    y: .value("Steps", item.stepCount ?? 0)
                            //                                )
                            //                            }
                            StepsChartView(data: vm.weeklySnapshots)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "figure.stair.stepper")
                                                .bold()
                                            Text("Steps Today")
                                                .bold()
                                                .font(.system(.subheadline, design: .rounded))
                                        }
                                        .foregroundStyle(.blue)
                                        Text(vm.formattedSteps)
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(16)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                // }
                    
                // speed + length group cards HStack
                HStack(spacing: 16) {
                    // walking speed
                    // NavigationStack {
                    NavigationLink {
                        SpeedChartView(data: vm.weeklySnapshots)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "speedometer")
                                            .frame(alignment: .leading)
                                        Text("Walking Speed")
                                            .bold()
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundStyle(.orange)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .foregroundStyle(.orange)
                                    Text(vm.formattedSpeed)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                }
                                Spacer()
                            }
                        }
                    }
                    // .frame(maxWidth: .infinity, maxHeight: 50, alignment: .topLeading)
                    .frame(maxWidth: .infinity, maxHeight: 75, alignment: .topLeading)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    // }
                    .buttonStyle(.plain)
                        
                    // step length
                    // NavigationStack {
                    NavigationLink {
                        LengthChartView(data: vm.weeklySnapshots)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "ruler.fill")
                                            .bold()
                                        Text("Step Length")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundStyle(.orange)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .foregroundStyle(.orange)
                                    Text(vm.formattedStepLength)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                    Text("per stride")
                                        
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 75, alignment: .topLeading)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                // }
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
                    
                // double support + asymmetry group cards HStack
                HStack(spacing: 16) {
                    // double support
                    // NavigationStack {
                    NavigationLink {
                        DSChartView(data: vm.weeklySnapshots)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "scalemass.fill")
                                            .bold()
                                            .font(.system(size: 14))
                                        
                                        Text("Double Support")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundStyle(.orange)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        

                                    }
                                    .foregroundStyle(.orange)
                                    Text(vm.formattedDoubleSupport)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                    Text("both feet on ground")
                                        
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    // .frame(maxWidth: .infinity, maxHeight: 50, alignment: .topLeading)
                    .frame(maxWidth: .infinity, maxHeight: 75, alignment: .topLeading)
                    // .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    // }
                    .buttonStyle(.plain)
                        
                    // asymmetry
                    // NavigationStack {
                    NavigationLink {
                        AsymChartView(data: vm.weeklySnapshots)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "arrow.left.and.right")
                                            .bold()
                                        // .frame(width: 20, alignment: .leading)
                                        Text("Asymmetry")
                                            .bold()
                                            .font(.subheadline)
                                            .foregroundStyle(.orange)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)

                                    }
                                    .foregroundStyle(.orange)
                                    Text(vm.formattedAsymmetry)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                    Text("left vs right")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 75, alignment: .topLeading)
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                // }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                    
                // steadiness card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "waveform.path.ecg")
                                        .bold()
                                    // .frame(width: 20, alignment: .leading)
                                    Text("Steadiness Score")
                                        .bold()
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                                .foregroundStyle(.green)
                                Text(vm.formattedSteadiness)
                                    .font(.system(size: 25, weight: .bold, design: .rounded))
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 5)
            }
            Spacer()
        }
    }
}

#Preview {
    @State var vm = DashboardViewModel()
    DashboardView(vm: vm)
        .preferredColorScheme(.dark)
}
