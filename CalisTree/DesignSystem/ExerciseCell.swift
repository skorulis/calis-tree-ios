// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct ExerciseCell: View {
    let exercise: Exercise
    let masteryProgress: Int

    var body: some View {
        HStack(spacing: 12) {
            image
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(exercise.level.displayTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            masteryIndicator
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var masteryIndicator: some View {
        switch masteryDisplay {
        case .hidden:
            EmptyView()
        case let .ring(progress):
            MasteryIndicatorView(progress: progress)
        case .star:
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundStyle(Color(red: 1, green: 0.78, blue: 0))
                .accessibilityLabel("Mastered")
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageFile = exercise.imageFile {
            Image(imageFile)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .padding(12)
        }
    }

    private var masteryDisplay: MasteryDisplay {
        guard let target = exercise.mastery else { return .hidden }
        guard masteryProgress > 0 else { return .hidden }
        if masteryProgress >= target.intValue {
            return .star
        }
        return .ring(progress: Double(masteryProgress) / Double(target.intValue))
    }

    private enum MasteryDisplay {
        case hidden
        case ring(progress: Double)
        case star
    }
}

#Preview("In progress") {
    ExerciseCell(
        exercise: Exercise(
            name: "Hanging L-Sit",
            description: nil,
            level: .beginner,
            imageFile: "l-sit",
            videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY",
            equipment: [.overheadBar],
            mastery: .time(30),
            prerequisites: []
        ),
        masteryProgress: 15
    )
    .padding()
}

#Preview("Mastered") {
    ExerciseCell(
        exercise: Exercise(
            name: "Pull up",
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
    .padding()
}

#Preview("No mastery") {
    ExerciseCell(
        exercise: Exercise(
            name: "Hanging High Knee Raise",
            description: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=oDiqwy0Y964",
            equipment: [.overheadBar],
            mastery: nil,
            prerequisites: []
        ),
        masteryProgress: 0
    )
    .padding()
}
