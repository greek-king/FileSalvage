// Views/ScanningView.swift
// Active scan UI with animated progress

import SwiftUI

struct ScanningView: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @State private var rotationAngle: Double = 0
    @State private var scanLine: Double = 0

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Button(action: viewModel.cancelScan) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#8892A4"))
                }
                Spacer()
                Text(viewModel.selectedDepth.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#4ECDC4"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#4ECDC4").opacity(0.12))
                            .overlay(Capsule().strokeBorder(Color(hex: "#4ECDC4").opacity(0.3), lineWidth: 1))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            Spacer()

            // Animated radar
            ZStack {
                // Radar rings
                ForEach(0..<4) { i in
                    Circle()
                        .strokeBorder(Color(hex: "#4ECDC4").opacity(0.08 + Double(i) * 0.02), lineWidth: 1)
                        .frame(width: CGFloat(100 + i * 50), height: CGFloat(100 + i * 50))
                }

                // Spinning sweep
                ZStack {
                    // Radar sweep arc
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .stroke(
                            AngularGradient(
                                colors: [Color(hex: "#4ECDC4").opacity(0.5), Color.clear],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(90)
                            ),
                            lineWidth: 1
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(rotationAngle))

                    // Sweep line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#4ECDC4").opacity(0.8), Color.clear],
                                startPoint: .center,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 100, height: 1.5)
                        .offset(x: 50)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }

                // Center
                ZStack {
                    Circle()
                        .fill(Color(hex: "#0D1F2D"))
                        .frame(width: 80, height: 80)
                    Circle()
                        .strokeBorder(Color(hex: "#4ECDC4").opacity(0.4), lineWidth: 1.5)
                        .frame(width: 80, height: 80)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#4ECDC4"))
                }

                // Blips (found files)
                if viewModel.scanProgress.filesFound > 0 {
                    ForEach(0..<min(8, viewModel.scanProgress.filesFound / 3 + 1), id: \.self) { i in
                        BlipView(index: i)
                    }
                }
            }
            .frame(width: 250, height: 250)

            Spacer().frame(height: 40)

            // Progress info
            VStack(spacing: 16) {
                // Step name
                Text(viewModel.scanProgress.currentStep)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: viewModel.scanProgress.currentStep)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "#1A2035"))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#4ECDC4"), Color(hex: "#2BD9CF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(8, geo.size.width * viewModel.scanProgress.percentage),
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: viewModel.scanProgress.percentage)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                // Stats
                HStack(spacing: 32) {
                    StatItem(
                        label: "Files Found",
                        value: "\(viewModel.scanProgress.filesFound)",
                        color: "#4ECDC4"
                    )
                    StatItem(
                        label: "Progress",
                        value: "\(Int(viewModel.scanProgress.percentage * 100))%",
                        color: "#A855F7"
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Tip
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#F59E0B"))
                Text("Keep the app open during scanning for best results")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#6B7280"))
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Blip View
struct BlipView: View {
    let index: Int
    @State private var opacity: Double = 0

    static let positions: [CGPoint] = [
        CGPoint(x: 40, y: -60), CGPoint(x: -70, y: 30),
        CGPoint(x: 80, y: 40), CGPoint(x: -30, y: -80),
        CGPoint(x: 60, y: 70), CGPoint(x: -80, y: -40),
        CGPoint(x: -50, y: 65), CGPoint(x: 90, y: -20)
    ]

    var body: some View {
        let pos = BlipView.positions[index % BlipView.positions.count]

        Circle()
            .fill(Color(hex: "#4ECDC4"))
            .frame(width: 6, height: 6)
            .shadow(color: Color(hex: "#4ECDC4").opacity(0.8), radius: 4)
            .opacity(opacity)
            .offset(x: pos.x, y: pos.y)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(Double(index) * 0.2)) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    let color: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: color))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#6B7280"))
        }
    }
}
