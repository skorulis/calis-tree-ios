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
                    .foregroundStyle(.secondary)
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
        .frame(width: Self.size, height: Self.size)
        .padding(Self.lineWidth / 2)
    }

    @ViewBuilder
    private var ringOverlay: some View {
        switch borderState {
        case .notStarted:
            Circle()
                .stroke(Color.secondary, lineWidth: Self.lineWidth)
        case let .inProgress(fraction):
            ZStack {
                Circle()
                    .stroke(Color.secondary, lineWidth: Self.lineWidth)
                Circle()
                    .trim(from: 0, to: min(max(fraction, 0), 1))
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        case .mastered:
            Circle()
                .stroke(Palette.Mastery.gold, lineWidth: Self.lineWidth)
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
                .foregroundStyle(.secondary)
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

#Preview("Not started") {
    ExerciseAvatar(
        exercise: Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .none
    )
}

#Preview("In progress") {
    ExerciseAvatar(
        exercise: Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .init(progression: ["hold": .init(current: 5, target: 10)])
    )
}

#Preview("Mastered") {
    ExerciseAvatar(
        exercise: Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .init(progression: ["hold": .init(current: 10, target: 10)])
    )
}

#Preview("With name") {
    ExerciseAvatar(
        exercise: Exercise(
            id: "pull_up",
            name: "Pull Up",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .none,
        showName: true
    )
}
