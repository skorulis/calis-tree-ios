// Created by Alex Skorulis on 15/5/2026.

import ASKCoordinator
import ASKCore
import SwiftUI

struct ExerciseListView: View {
    let repository: ExerciseRepository
    @Bindable var mainStore: MainStore

    @Environment(\.coordinator) private var coordinator

    var body: some View {
        List {
            ForEach(repository.exercises, id: \.name) { exercise in
                Button {
                    coordinator?.push(MainPath.exerciseDetail(exercise))
                } label: {
                    ExerciseCell(
                        exercise: exercise,
                        masteryProgress: mainStore.masteryProgress(for: exercise.name)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Exercises")
    }
}

#Preview {
    let mainStore = MainStore(keyValueStore: InMemoryDefaults())
    mainStore.setMasteryProgress(15, for: "Hanging L-Sit")
    return NavigationStack {
        ExerciseListView(
            repository: ExerciseRepository(),
            mainStore: mainStore
        )
    }
    .environment(\.coordinator, Coordinator(root: MainPath.exerciseList))
}
