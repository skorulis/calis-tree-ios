// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct ExerciseAvatar: View {
    let exercise: Exercise
    let masteryProgress: ExerciseProgress
    var showName: Bool = false

    private static let size: CGFloat = 60
    private static let lineWidth: CGFloat = 3

    var body: some View {
        VStack(spacing: 4) {
            circle
            if showName {
                Text(exercise.displayName)
                    .font(.caption2)
                    .foregroundStyle(Palette.Level.foundation)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(width: Self.size)
            }
        }
        .frame(width: Self.size)
        .accessibilityLabel(accessibilityLabel)
    }

    private var circle: some View {
        ZStack {
            image
                .frame(width: Self.size - Self.lineWidth * 2, height: Self.size - Self.lineWidth * 2)
                .background(Color.white)
                .clipShape(Circle())
            ringOverlay
        }
        .padding(Self.lineWidth / 2)
    }

    @ViewBuilder
    private var ringOverlay: some View {
        switch borderState {
        case .notStarted:
            Circle()
                .stroke(Palette.Level.foundation, lineWidth: Self.lineWidth)
        case let .inProgress(fraction):
            ZStack {
                Circle()
                    .stroke(Palette.Level.foundation, lineWidth: Self.lineWidth)
                Circle()
                    .trim(from: 0, to: min(max(fraction, 0), 1))
                    .stroke(
                        Palette.Progress.inProgress,
                        style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        case .mastered:
            Circle()
                .stroke(Palette.Progress.complete, lineWidth: Self.lineWidth)
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageFile = exercise.imageFile {
            Image(imageFile)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(12)
                .foregroundStyle(Palette.Level.foundation)
        }
    }

    private var borderState: BorderState {
        if masteryProgress.fraction >= 1 {
            return .mastered
        }
        if masteryProgress.fraction > 0 {
            return .inProgress(masteryProgress.fraction)
        }
        return .notStarted
    }

    private var accessibilityLabel: String {
        let state: String
        switch borderState {
        case .notStarted:
            state = "not started"
        case .inProgress:
            state = "in progress"
        case .mastered:
            state = "mastered"
        }
        return "\(exercise.displayName), \(state)"
    }

    private enum BorderState {
        case notStarted
        case inProgress(Double)
        case mastered
    }
}

#Preview("Progress") {
    HStack {
        ExerciseAvatar(
            exercise: .Preview.pullUp,
            masteryProgress: .none
        )
        
        ExerciseAvatar(
            exercise: .Preview.pullUp,
            masteryProgress: .init(progression: ["hold": .init(current: 5, target: 10)])
        )
        
        ExerciseAvatar(
            exercise: .Preview.pullUp,
            masteryProgress: .init(progression: ["hold": .init(current: 10, target: 10)])
        )
    }
    .padding()
    .background(Palette.Level.beginner.opacity(0.25))
    
}

#Preview("With name") {
    ExerciseAvatar(
        exercise: .Preview.pullUp,
        masteryProgress: .none,
        showName: true
    )
}
