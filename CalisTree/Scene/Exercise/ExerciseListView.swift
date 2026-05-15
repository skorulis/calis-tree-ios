// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import SwiftUI

struct ExerciseListView: View {
    let repository: ExerciseRepository

    @Environment(\.coordinator) private var coordinator

    var body: some View {
        List {
            ForEach(repository.exercises, id: \.name) { exercise in
                Button {
                    coordinator?.push(MainPath.exerciseDetail(exercise))
                } label: {
                    ExerciseCell(exercise: exercise)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Exercises")
    }
}

#Preview {
    NavigationStack {
        ExerciseListView(repository: ExerciseRepository())
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
