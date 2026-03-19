// Views/HomeView.swift
// Landing screen with scan options and history

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ScanViewModel
    @EnvironmentObject var recoveryStore: RecoveryStore
    @State private var animatePulse = false
    @State private var showDepthPicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // Header
                headerSection

                // Hero scan button
                scanHeroSection
                    .padding(.top, 32)

                // Scan depth selector
                scanDepthSection
                    .padding(.top, 28)

                // Feature tiles
                featureTilesSection
                    .padding(.top, 32)

                // Recent sessions
                if !recoveryStore.sessions.isEmpty {
                    recentSessionsSection
                        .padding(.top, 32)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
            recoveryStore.loadSessions()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("FileSalvage")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#4ECDC4"), Color(hex: "#44A8B3")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Data Recovery & Restore")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#8892A4"))
            }

            Spacer()

            // Settings / history button
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#141928"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(Color(hex: "#2A3352"), lineWidth: 1)
                        )
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "#4ECDC4"))
                }
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Scan Hero

    private var scanHeroSection: some View {
        VStack(spacing: 24) {
            // Animated radar visualization
            ZStack {
                // Outer rings
                ForEach(0..<3) { i in
                    Circle()
                        .strokeBorder(
                            Color(hex: "#4ECDC4").opacity(0.15 - Double(i) * 0.04),
                            lineWidth: 1
                        )
                        .frame(width: CGFloat(140 + i * 40), height: CGFloat(140 + i * 40))
                        .scaleEffect(animatePulse ? 1.05 + Double(i) * 0.02 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.3),
                            value: animatePulse
                        )
                }

                // Main button
                Button(action: viewModel.startScan) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "#1E3A4A"), Color(hex: "#0D1F2D")],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 70
                                )
                            )
                            .frame(width: 140, height: 140)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color(hex: "#4ECDC4"), Color(hex: "#1A6B75")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color(hex: "#4ECDC4").opacity(0.3), radius: 20)

                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#4ECDC4"), Color(hex: "#68E8DF")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                            Text("START SCAN")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "#4ECDC4"))
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
            }

            VStack(spacing: 6) {
                Text("Detect Recoverable Files")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Scan your device for deleted photos, videos,\ndocuments and more")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8892A4"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
    }

    // MARK: - Scan Depth

    private var scanDepthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scan Depth")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#8892A4"))
                .tracking(0.5)

            HStack(spacing: 10) {
                ForEach(ScanDepth.allCases, id: \.self) { depth in
                    DepthOptionButton(
                        depth: depth,
                        isSelected: viewModel.selectedDepth == depth,
                        action: { viewModel.selectedDepth = depth }
                    )
                }
            }
        }
    }

    // MARK: - Feature Tiles

    private var featureTilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What We Recover")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#8892A4"))
                .tracking(0.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FileType.allCases.filter { $0 != .unknown }, id: \.self) { type in
                    FileTypeTile(fileType: type)
                }
            }
        }
    }

    // MARK: - Recent Sessions

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Recovery Sessions")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "#8892A4"))
                .tracking(0.5)

            ForEach(recoveryStore.sessions.prefix(3)) { session in
                SessionRow(session: session)
            }
        }
    }
}

// MARK: - Depth Option Button
struct DepthOptionButton: View {
    let depth: ScanDepth
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color(hex: "#4ECDC4").opacity(0.15) : Color(hex: "#141928"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    isSelected ? Color(hex: "#4ECDC4").opacity(0.6) : Color(hex: "#2A3352"),
                                    lineWidth: 1
                                )
                        )

                    VStack(spacing: 4) {
                        Image(systemName: depthIcon)
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? Color(hex: "#4ECDC4") : Color(hex: "#4B5563"))

                        Text(depthLabel)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(isSelected ? Color(hex: "#4ECDC4") : Color(hex: "#6B7280"))
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    var depthIcon: String {
        switch depth {
        case .quick: return "bolt.fill"
        case .deep:  return "magnifyingglass"
        case .full:  return "scope"
        }
    }

    var depthLabel: String {
        switch depth {
        case .quick: return "QUICK"
        case .deep:  return "DEEP"
        case .full:  return "FULL"
        }
    }
}

// MARK: - File Type Tile
struct FileTypeTile: View {
    let fileType: FileType

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "#141928"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color(hex: "#2A3352"), lineWidth: 1)
            )
            .frame(height: 80)
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: fileType.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: fileType.color))

                    Text(fileType.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "#8892A4"))
                }
            )
    }
}

// MARK: - Session Row
struct SessionRow: View {
    let session: RecoverySession

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#141928"))
                    .frame(width: 40, height: 40)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#10B981"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(session.recoveredFiles.count) files recovered")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(session.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#6B7280"))
            }

            Spacer()

            Text(ByteCountFormatter.string(fromByteCount: session.totalSize, countStyle: .file))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#4ECDC4"))
        }
        .padding(14)
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
