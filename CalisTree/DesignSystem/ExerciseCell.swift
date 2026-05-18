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
                Chip(level: exercise.safeLevel)
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
        exercise: .Preview.hangingLSit,
        masteryProgress: .none
    )
    .padding()
}

#Preview("Mastered") {
    ExerciseCell(
        exercise: .Preview.pullUp,
        masteryProgress: .none
    )
    .padding()
}

#Preview("No mastery") {
    ExerciseCell(
        exercise: .Preview.hangingHighKneeRaiseWithoutMastery,
        masteryProgress: .none
    )
    .padding()
}
