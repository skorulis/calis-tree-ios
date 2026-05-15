// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct MasteryIndicatorView: View {
    let mastery: SetType?
    let masteryProgress: Int

    var body: some View {
        switch display {
        case .hidden:
            EmptyView()
        case let .ring(fraction):
            ring(fraction: fraction)
        case .star:
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundStyle(Color(red: 1, green: 0.78, blue: 0))
                .accessibilityLabel("Mastered")
        }
    }

    private var display: Display {
        guard let target = mastery else { return .hidden }
        guard masteryProgress > 0 else { return .hidden }
        if masteryProgress >= target.intValue {
            return .star
        }
        return .ring(progress: Double(masteryProgress) / Double(target.intValue))
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

#Preview("In progress") {
    MasteryIndicatorView(mastery: .time(30), masteryProgress: 15)
}

#Preview("Mastered") {
    MasteryIndicatorView(mastery: .reps(20), masteryProgress: 20)
}

#Preview("Hidden") {
    HStack(spacing: 24) {
        MasteryIndicatorView(mastery: nil, masteryProgress: 10)
        MasteryIndicatorView(mastery: .time(30), masteryProgress: 0)
    }
}
