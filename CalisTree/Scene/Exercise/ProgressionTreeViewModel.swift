// Created by Alex Skorulis on 18/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class ProgressionTreeViewModel: CoordinatorViewModel {
    let exercise: Exercise
    private let mainStore: MainStore
    private let repository: ExerciseRepository
    private let layoutService: ProgressionTreeLayoutService

    weak var coordinator: Coordinator?

    @Resolvable<Resolver>
    init(
        @Argument exercise: Exercise,
        mainStore: MainStore,
        repository: ExerciseRepository,
        layoutService: ProgressionTreeLayoutService
    ) {
        self.exercise = exercise
        self.mainStore = mainStore
        self.repository = repository
        self.layoutService = layoutService
    }

    var treeModel: ProgressionTreeModel {
        let exercises = repository.progressionChain(to: exercise.id)
        return layoutService.build(from: exercises)
    }

    func masteryProgress(for exercise: Exercise) -> ExerciseProgress {
        mainStore.effectiveMasteryProgress(for: exercise)
    }
}

// MARK: - Actions

extension ProgressionTreeViewModel {
    func showDetails(exercise: Exercise) {
        coordinator?.push(MainPath.exerciseDetail(exercise))
    }
}
