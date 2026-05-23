// Created by Alex Skorulis on 16/5/2026.

import SwiftUI
import UIKit

struct TimerView: View {
    /// When false (e.g. another tab selected), an active microphone session is ended so SwiftUI TabView quirks do not leave audio running.
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
        .onAppear {
            voice.setActions(start: startIfPaused, stop: pauseIfRunning)
        }
        .onChange(of: voiceListeningShouldBeActive) { _, shouldAllowVoice in
            if !shouldAllowVoice {
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

    @ViewBuilder
    private var voiceStatus: some View {
        if voice.voiceUnavailable {
            Text("Voice commands need microphone and speech recognition access in Settings.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        } else {
            Label("Listening for “start timer” or “stop timer”", systemImage: "mic.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHint("Speak clearly to control the timer")
                .opacity(voice.isListening ? 1 : 0)
        }
    }

    private func startIfPaused() -> Bool {
        guard runningSince == nil else { return false }
        runningSince = Date()
        return true
    }

    private func pauseIfRunning() -> Bool {
        guard let start = runningSince else { return false }
        accumulatedElapsed += Date().timeIntervalSince(start)
        runningSince = nil
        return true
    }
    
    private var buttons: some View {
        VStack(spacing: 16) {
            microphoneButton
            toggleButton
            resetButton
        }
    }

    private var microphoneButton: some View {
        Button(action: toggleVoiceListening) {
            Image(systemName: voice.isListening ? "mic.circle.fill" : "mic.circle")
                .font(.system(size: 56))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(voice.isListening ? Color.green : Color.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(voice.isListening ? "Stop voice control" : "Start voice control")
        .accessibilityHint("Say “start timer” or “stop timer” to control the timer")
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
            _ = pauseIfRunning()
        } else {
            _ = startIfPaused()
        }
    }

    private func toggleVoiceListening() {
        if voice.isListening {
            voice.endListeningSession()
        } else {
            Task {
                await voice.beginListeningSession()
            }
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
