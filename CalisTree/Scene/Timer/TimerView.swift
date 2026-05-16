// Created by Alex Skorulis on 16/5/2026.

import SwiftUI

struct TimerView: View {
    @State private var accumulatedElapsed: TimeInterval = 0
    @State private var runningSince: Date?

    private var isRunning: Bool { runningSince != nil }

    private func elapsed(at date: Date) -> TimeInterval {
        accumulatedElapsed + (runningSince.map { date.timeIntervalSince($0) } ?? 0)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            buttons
            timeLabel
                .padding(.bottom, 64)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var buttons: some View {
        VStack {
            toggleButton
            resetButton
        }
    }

    private var toggleButton: some View {
        Button(action: toggleRunning) {
            Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 112))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRunning ? "Pause" : "Start")
    }

    @ViewBuilder
    private var timeLabel: some View {
        if isRunning {
            TimelineView(.periodic(from: .now, by: 1.0 / 60.0)) { context in
                Text(Self.formatStopwatch(elapsed(at: context.date)))
                    .font(.system(size: 40, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .accessibilityLabel("Elapsed time \(Self.formatStopwatch(elapsed(at: context.date)))")
            }
        } else {
            Text(Self.formatStopwatch(accumulatedElapsed))
                .font(.system(size: 40, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .accessibilityLabel("Elapsed time \(Self.formatStopwatch(accumulatedElapsed))")
        }
    }

    @ViewBuilder
    private var resetButton: some View {
        Button("Reset", action: reset)
            .buttonStyle(.bordered)
            .accessibilityLabel("Reset timer")
            .opacity(isRunning ? 0 : 1)
    }

    private func toggleRunning() {
        if let start = runningSince {
            accumulatedElapsed += Date().timeIntervalSince(start)
            runningSince = nil
        } else {
            runningSince = Date()
        }
    }

    private func reset() {
        accumulatedElapsed = 0
        runningSince = nil
    }

    private static func formatStopwatch(_ interval: TimeInterval) -> String {
        let clamped = max(0, interval)
        let totalMs = Int((clamped * 1000).rounded(.down))
        let msComponent = totalMs % 1000
        let totalSeconds = totalMs / 1000
        let s = totalSeconds % 60
        let m = (totalSeconds / 60) % 60
        let h = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d.%03d", h, m, s, msComponent)
    }
}

#Preview {
    NavigationStack {
        TimerView()
            .navigationTitle("Timer")
    }
}
