// Created by Alex Skorulis on 17/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class ExerciseProgressionViewModel: CoordinatorViewModel {
    let exercise: Exercise
    private let mainStore: MainStore
    private let repository: ExerciseRepository

    weak var coordinator: Coordinator?

    @Resolvable<Resolver>
    init(@Argument exercise: Exercise, mainStore: MainStore, repository: ExerciseRepository) {
        self.exercise = exercise
        self.mainStore = mainStore
        self.repository = repository
    }

    var items: [ExerciseListItem] {
        repository.progressionChain(to: exercise.id).map { exercise in
            ExerciseListItem(
                exercise: exercise,
                masteryProgress: mainStore.effectiveMasteryProgress(for: exercise)
            )
        }
    }
}

// MARK: - Actions

extension ExerciseProgressionViewModel {
    func showDetails(exercise: Exercise) {
        coordinator?.push(MainPath.exerciseDetail(exercise))
    }
}
