// Views/RecoveryViews.swift
// Recovery progress, destination picker, and completion screens

import SwiftUI

// MARK: - Recovery Destination Sheet
struct RecoveryDestinationSheet: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0A0E1A").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    Text("Choose Recovery Destination")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 24)
                        .padding(.bottom, 8)

                    Text("Where would you like to save recovered files?")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#8892A4"))
                        .padding(.bottom, 32)

                    // Destination options
                    VStack(spacing: 12) {
                        DestinationOption(
                            icon: "photo.on.rectangle.angled",
                            title: "Camera Roll",
                            subtitle: "Save photos & videos back to Photos",
                            color: "#4ECDC4"
                        ) {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.recoverSelected(to: .cameraRoll)
                            }
                        }

                        DestinationOption(
                            icon: "folder.fill",
                            title: "Files App",
                            subtitle: "Save to 'Recovered Files' folder",
                            color: "#3B82F6"
                        ) {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyyMMdd_HHmmss"
                            let folderName = "Recovery_\(formatter.string(from: Date()))"
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.recoverSelected(to: .files(folderName: folderName))
                            }
                        }

                        DestinationOption(
                            icon: "icloud.and.arrow.up",
                            title: "iCloud Drive",
                            subtitle: "Sync recovered files to iCloud",
                            color: "#A855F7"
                        ) {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.recoverSelected(to: .iCloud)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#8892A4"))
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Destination Option
struct DestinationOption: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: color).opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: color))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8892A4"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#4B5563"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#141928"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color(hex: "#2A3352"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Recovering View
struct RecoveringView: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @State private var waveOffset: CGFloat = 0

    var progress: Double {
        viewModel.recoveryProgress?.percentage ?? 0
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated progress orb
            ZStack {
                // Outer glow ring
                Circle()
                    .strokeBorder(
                        Color(hex: "#4ECDC4").opacity(0.15 + progress * 0.15),
                        lineWidth: 2
                    )
                    .frame(width: 220, height: 220)

                Circle()
                    .strokeBorder(Color(hex: "#2A3352"), lineWidth: 1.5)
                    .frame(width: 180, height: 180)

                // Fill progress
                ZStack {
                    Circle()
                        .fill(Color(hex: "#0D1F2D"))
                        .frame(width: 176, height: 176)

                    // Wave fill effect (simplified with gradient)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#4ECDC4").opacity(0.3),
                                    Color(hex: "#4ECDC4").opacity(0.1)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 176, height: 176 * progress)
                        .offset(y: 88 - 88 * progress)
                        .clipShape(Circle())
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    // Percentage
                    VStack(spacing: 4) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Recovering")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#4ECDC4"))
                            .tracking(1)
                    }
                }
                .clipShape(Circle())
                .frame(width: 176, height: 176)
            }

            Spacer().frame(height: 40)

            // Current file
            if let progress = viewModel.recoveryProgress {
                VStack(spacing: 12) {
                    Text("Recovering file...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#6B7280"))

                    Text(progress.currentFile)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 40)

                    Text("\(progress.completedCount) of \(progress.totalCount) files")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#8892A4"))

                    if !progress.failedFiles.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#F59E0B"))
                            Text("\(progress.failedFiles.count) files could not be recovered")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#F59E0B"))
                        }
                        .padding(.top, 4)
                    }
                }
            }

            Spacer()

            Text("Please keep the app open during recovery")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#4B5563"))
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Recovery Complete View
struct RecoveryCompleteView: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @EnvironmentObject var recoveryStore: RecoveryStore
    @State private var showConfetti = false
    @State private var animateCheck = false

    var result: RecoveryOperationResult? { viewModel.recoveryResult }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Success animation
            ZStack {
                // Radiating circles
                ForEach(0..<3) { i in
                    Circle()
                        .strokeBorder(Color(hex: "#10B981").opacity(showConfetti ? 0 : 0.3 - Double(i) * 0.08), lineWidth: 1.5)
                        .frame(width: CGFloat(100 + i * 50), height: CGFloat(100 + i * 50))
                        .scaleEffect(showConfetti ? CGFloat(2.5 + Double(i) * 0.3) : 1.0)
                        .animation(
                            .easeOut(duration: 1.5).delay(Double(i) * 0.15),
                            value: showConfetti
                        )
                }

                // Check circle
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#10B981").opacity(0.3), Color(hex: "#0D1F2D")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                    Circle()
                        .strokeBorder(Color(hex: "#10B981"), lineWidth: 2)
                        .frame(width: 110, height: 110)

                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "#10B981"))
                        .scaleEffect(animateCheck ? 1.0 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: animateCheck)
                }
            }
            .onAppear {
                showConfetti = true
                animateCheck = true
                saveSession()
            }

            Spacer().frame(height: 40)

            // Result stats
            VStack(spacing: 10) {
                Text("Recovery Complete!")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)

                if let result = result {
                    Text("\(result.succeededFiles.count) files successfully recovered")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#8892A4"))
                }
            }

            Spacer().frame(height: 32)

            // Stats grid
            if let result = result {
                HStack(spacing: 12) {
                    ResultStatCard(
                        icon: "checkmark.circle.fill",
                        value: "\(result.succeededFiles.count)",
                        label: "Recovered",
                        color: "#10B981"
                    )
                    ResultStatCard(
                        icon: "xmark.circle.fill",
                        value: "\(result.failedFiles.count)",
                        label: "Failed",
                        color: result.failedFiles.isEmpty ? "#6B7280" : "#FF6B6B"
                    )
                    ResultStatCard(
                        icon: "externaldrive.fill",
                        value: ByteCountFormatter.string(fromByteCount: result.totalRecovered, countStyle: .file),
                        label: "Total Size",
                        color: "#4ECDC4"
                    )
                }
                .padding(.horizontal, 20)

                if result.successRate < 1.0 && !result.failedFiles.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#F59E0B"))
                        Text("\(result.failedFiles.count) files could not be fully recovered due to overwriting")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8892A4"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button(action: viewModel.rescan) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Scan Again")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#4ECDC4"), Color(hex: "#2BD9CF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color(hex: "#4ECDC4").opacity(0.4), radius: 15)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)

                Button(action: viewModel.resetToHome) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#8892A4"))
                        .padding(.vertical, 14)
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func saveSession() {
        guard let result = result else { return }
        let session = RecoverySession(
            id: UUID(),
            date: Date(),
            recoveredFiles: result.succeededFiles,
            destinationPath: result.destinationURL?.path ?? "Device",
            status: result.failedFiles.isEmpty ? .completed : .partial
        )
        recoveryStore.addSession(session)
    }
}

// MARK: - Result Stat Card
struct ResultStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color(hex: color))

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(hex: "#6B7280"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#141928"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(hex: "#2A3352"), lineWidth: 1)
                )
        )
    }
}
