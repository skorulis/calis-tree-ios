// Created by Alex Skorulis on 15/5/2026.

import SwiftUI

struct ExerciseCell: View {
    let exercise: Exercise
    let masteryProgress: ExerciseProgress

    var body: some View {
        HStack(spacing: 12) {
            ExerciseAvatar(exercise: exercise, masteryProgress: masteryProgress)
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Chip(level: exercise.level)
            }
            Spacer(minLength: 0)
            MasteryIndicatorView(
                masteryProgress: masteryProgress
            )
        }
        .contentShape(Rectangle())
    }
}

#Preview("In progress") {
    ExerciseCell(
        exercise: Exercise(
            id: "hanging_l_sit",
            name: "Hanging L-Sit",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: "l-sit",
            videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY",
            equipment: [.overheadBar],
            mastery: .time(30),
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .none
    )
    .padding()
}

#Preview("Mastered") {
    ExerciseCell(
        exercise: Exercise(
            id: "pull_up",
            name: "Pull up",
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
    .padding()
}

#Preview("No mastery") {
    ExerciseCell(
        exercise: Exercise(
            id: "hanging_high_knee_raise",
            name: "Hanging High Knee Raise",
            description: nil,
            steps: nil,
            level: .beginner,
            imageFile: nil,
            videoURL: "https://www.youtube.com/watch?v=oDiqwy0Y964",
            equipment: [.overheadBar],
            mastery: nil,
            progression: nil,
            prerequisites: []
        ),
        masteryProgress: .none
    )
    .padding()
}
