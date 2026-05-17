// Created by Alex Skorulis on 16/5/2026.

import SwiftUI
import UIKit

struct TimerView: View {
    /// When false (e.g. another tab selected), microphone listening is paused so SwiftUI TabView quirks do not leave audio running.
    var voiceListeningShouldBeActive: Bool = true

    @State private var accumulatedElapsed: TimeInterval = 0
    @State private var runningSince: Date?
    @State private var voice = TimerVoiceCommandController()

    private var isRunning: Bool { runningSince != nil }

    private func elapsed(at date: Date) -> TimeInterval {
        accumulatedElapsed + (runningSince.map { date.timeIntervalSince($0) } ?? 0)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            voiceStatus
            buttons
            timeLabel
                .padding(.bottom, 64)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: voiceListeningShouldBeActive) {
            voice.setActions(start: startIfPaused, stop: pauseIfRunning)
            if voiceListeningShouldBeActive {
                await voice.beginListeningSession()
            } else {
                voice.endListeningSession()
            }
        }
        .onChange(of: isRunning) { _, running in
            UIApplication.shared.isIdleTimerDisabled = running
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            voice.endListeningSession()
        }
    }

    private var voiceStatus: some View {
        Group {
            if voice.isListening {
                Label("Listening for “start timer” or “stop timer”", systemImage: "mic.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityHint("Speak clearly to control the timer")
            } else if voice.voiceUnavailable {
                Text("Voice commands need microphone and speech recognition access in Settings.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
    }

    private func startIfPaused() {
        guard runningSince == nil else { return }
        runningSince = Date()
    }

    private func pauseIfRunning() {
        guard let start = runningSince else { return }
        accumulatedElapsed += Date().timeIntervalSince(start)
        runningSince = nil
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
        if runningSince != nil {
            pauseIfRunning()
        } else {
            startIfPaused()
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
