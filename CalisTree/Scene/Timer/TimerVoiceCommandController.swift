// Created by Alex Skorulis on 16/5/2026.

import AVFoundation
import Foundation
import Observation
import Speech

/// Captures mic audio and maps phrases like "start timer" / "stop timer" to actions while the timer screen is visible.
@MainActor
@Observable
final class TimerVoiceCommandController {

    private enum VoiceCommand {
        case startTimer
        case stopTimer
    }

    /// Engine running and recognition tasks are active.
    private(set) var isListening = false

    /// Authorization failed, recognizer unavailable, or setup error.
    private(set) var voiceUnavailable = false

    private let cooldown: TimeInterval = 1
    private var lastCommandTime: Date?

    private var speechRecognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private let bufferTarget = BufferRequestTarget()
    private var recognitionTask: SFSpeechRecognitionTask?

    private var shouldRun = false

    private var startAction: () -> Void = {}
    private var stopAction: () -> Void = {}

    func setActions(start: @escaping () -> Void, stop: @escaping () -> Void) {
        startAction = start
        stopAction = stop
    }

    func beginListeningSession() async {
        if isListening {
            endListeningSession()
        }
        shouldRun = true
        voiceUnavailable = false

        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        #endif

        let speechStatus = await requestSpeechAuthorization()
        guard speechStatus == .authorized else {
            voiceUnavailable = speechStatus != .notDetermined
            return
        }

        let micGranted = await requestMicrophonePermission()
        guard micGranted else {
            voiceUnavailable = true
            return
        }

        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            voiceUnavailable = true
            return
        }

        do {
            try configureAudioSession()
            try ensureEngineRunning()
            try swapRecognitionPipeline()
            isListening = true
        } catch {
            voiceUnavailable = true
            endListeningSession()
        }
    }

    func endListeningSession() {
        shouldRun = false
        recognitionTask?.cancel()
        recognitionTask = nil
        bufferTarget.endAndClear()
        if let engine = audioEngine {
            if engine.isRunning {
                engine.stop()
            }
            engine.inputNode.removeTap(onBus: 0)
        }
        audioEngine = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isListening = false
    }

    // MARK: - Recognition

    private func swapRecognitionPipeline() throws {
        guard shouldRun else { return }
        guard let speechRecognizer, speechRecognizer.isAvailable else { return }

        recognitionTask?.cancel()
        recognitionTask = nil
        bufferTarget.endAndClear()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if speechRecognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        bufferTarget.setRequest(request)

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                self.handleRecognition(result: result, error: error)
            }
        }
    }

    private func handleRecognition(result: SFSpeechRecognitionResult?, error: Error?) {
        guard shouldRun else { return }

        if let result {
            let text = result.bestTranscription.formattedString
            if let command = Self.latestCommand(in: Self.normalize(text)) {
                fireIfNeeded(command)
            }
            if result.isFinal {
                try? swapRecognitionPipeline()
            }
        }

        if let error {
            if Self.isBenignCancellation(error) {
                return
            }
            try? swapRecognitionPipeline()
        }
    }

    private func fireIfNeeded(_ command: VoiceCommand) {
        let now = Date()
        if let last = lastCommandTime, now.timeIntervalSince(last) < cooldown {
            return
        }
        lastCommandTime = now
        switch command {
        case .startTimer:
            startAction()
        case .stopTimer:
            stopAction()
        }
    }

    private static func normalize(_ transcript: String) -> String {
        let lower = transcript.lowercased()
        let condensed = lower.replacingOccurrences(
            of: "[^a-z0-9\\s]",
            with: " ",
            options: .regularExpression
        )
        return condensed.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func latestCommand(in normalized: String) -> VoiceCommand? {
        let phrases: [(String, VoiceCommand)] = [
            ("stop the timer", .stopTimer),
            ("pause the timer", .stopTimer),
            ("stop timer", .stopTimer),
            ("pause timer", .stopTimer),
            ("start the timer", .startTimer),
            ("start timer", .startTimer),
            ("start", .startTimer),
            ("stop", .stopTimer),
            ("pause", .stopTimer),
        ]
        var bestEnd: String.Index?
        var best: VoiceCommand?
        for (phrase, cmd) in phrases {
            var searchRange = normalized.startIndex..<normalized.endIndex
            while let range = normalized.range(of: phrase, options: [], range: searchRange) {
                if bestEnd == nil || range.upperBound > bestEnd! {
                    bestEnd = range.upperBound
                    best = cmd
                }
                searchRange = range.upperBound..<normalized.endIndex
            }
        }
        return best
    }

    private static func isBenignCancellation(_ error: Error) -> Bool {
        let ns = error as NSError
        // Common pattern when cancelling an in-flight recognition task intentionally.
        if ns.domain == "kAFAssistantErrorDomain", ns.code == 216 {
            return true
        }
        return false
    }

    // MARK: - Audio

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func ensureEngineRunning() throws {
        if audioEngine == nil {
            let engine = AVAudioEngine()
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 4096, format: format) { [bufferTarget] buffer, _ in
                bufferTarget.append(buffer)
            }
            audioEngine = engine
        }
        guard let engine = audioEngine else { return }
        if !engine.isRunning {
            engine.prepare()
            try engine.start()
        }
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    private func requestMicrophonePermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }
}

// MARK: - Buffer target

private final class BufferRequestTarget: @unchecked Sendable {

    private let lock = NSLock()
    nonisolated(unsafe) private var request: SFSpeechAudioBufferRecognitionRequest?

    func setRequest(_ newRequest: SFSpeechAudioBufferRecognitionRequest) {
        lock.lock()
        defer { lock.unlock() }
        request = newRequest
    }

    func endAndClear() {
        lock.lock()
        defer { lock.unlock() }
        request?.endAudio()
        request = nil
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        lock.lock()
        defer { lock.unlock() }
        request?.append(buffer)
    }
}
