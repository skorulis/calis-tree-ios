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
            MasteryIndicatorView(
                mastery: exercise.mastery,
                masteryProgress: masteryProgress
            )
        }
        .contentShape(Rectangle())
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
