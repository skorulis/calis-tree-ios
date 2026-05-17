// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct MasteryIndicatorView: View {
    let masteryProgress: ExerciseProgress

    var body: some View {
        switch display {
        case .hidden:
            EmptyView()
        case let .ring(fraction):
            ring(fraction: fraction)
        case .star:
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(Color(red: 1, green: 0.78, blue: 0))
                .accessibilityLabel("Mastered")
        }
    }

    private var display: Display {
        guard masteryProgress.fraction > 0 else { return .hidden }
        if masteryProgress.fraction >= 1 {
            return .star
        }
        return .ring(progress: masteryProgress.fraction)
    }

    private func ring(fraction: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.25), lineWidth: 3)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 28, height: 28)
        .accessibilityLabel("Mastery progress")
        .accessibilityValue("\(Int(fraction * 100)) percent")
    }

    private enum Display {
        case hidden
        case ring(progress: Double)
        case star
    }
}

#Preview {
    VStack {
        MasteryIndicatorView(masteryProgress: .init(main: .init(current: 5, target: 10), progression: [:]))
        MasteryIndicatorView(masteryProgress: .init(main: .init(current: 10, target: 10), progression: [:]))
        MasteryIndicatorView(masteryProgress: .none)
    }
    
}
