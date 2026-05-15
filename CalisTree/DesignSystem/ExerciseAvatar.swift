// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct ExerciseAvatar: View {
    let exercise: Exercise
    let masteryProgress: Int

    private static let size: CGFloat = 60
    private static let lineWidth: CGFloat = 3
    private static let gold = Color(red: 1, green: 0.78, blue: 0)

    var body: some View {
        ZStack {
            image
                .frame(width: Self.size - Self.lineWidth * 2, height: Self.size - Self.lineWidth * 2)
                .clipShape(Circle())
            ringOverlay
        }
        .frame(width: Self.size, height: Self.size)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var ringOverlay: some View {
        switch borderState {
        case .notStarted:
            Circle()
                .stroke(Color.secondary.opacity(0.35), lineWidth: Self.lineWidth)
        case let .inProgress(fraction):
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: Self.lineWidth)
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
                .stroke(Self.gold, lineWidth: Self.lineWidth)
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
        guard let target = exercise.mastery else { return .mastered }
        if masteryProgress >= target.intValue {
            return .mastered
        }
        if masteryProgress > 0 {
            return .inProgress(Double(masteryProgress) / Double(target.intValue))
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
        return "\(exercise.name), \(state)"
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
            name: "Pull Up",
            description: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            prerequisites: []
        ),
        masteryProgress: 0
    )
}

#Preview("In progress") {
    ExerciseAvatar(
        exercise: Exercise(
            name: "Pull Up",
            description: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            prerequisites: []
        ),
        masteryProgress: 10
    )
}

#Preview("Mastered") {
    ExerciseAvatar(
        exercise: Exercise(
            name: "Pull Up",
            description: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=XeErfmGSwfE",
            equipment: [.overheadBar],
            mastery: .reps(20),
            prerequisites: []
        ),
        masteryProgress: 20
    )
}
