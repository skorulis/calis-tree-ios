// Created by Alex Skorulis on 23/5/2026.

import AVFoundation

/// Short confirmation tones when a voice command is recognized.
enum TimerVoiceCommandFeedback {

    enum Kind {
        case start
        case stop
    }

    private static var startPlayer: AVAudioPlayer?
    private static var stopPlayer: AVAudioPlayer?

    static func prepare() {
        startPlayer = makePlayer(named: "timer_voice_start")
        stopPlayer = makePlayer(named: "timer_voice_stop")
    }

    static func play(_ kind: Kind) {
        let player: AVAudioPlayer? = switch kind {
        case .start: startPlayer
        case .stop: stopPlayer
        }
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }

    private static func makePlayer(named name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "caf") else {
            return nil
        }
        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        player.prepareToPlay()
        return player
    }
}
