// Created by Alex Skorulis on 18/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

@MainActor
@Observable
final class ProgressionTreeViewModel: CoordinatorViewModel {
    let scope: ProgressionTreeScope
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
        self.scope = .exercise(exercise)
        self.mainStore = mainStore
        self.repository = repository
        self.layoutService = layoutService
    }

    init(
        scope: ProgressionTreeScope,
        mainStore: MainStore,
        repository: ExerciseRepository,
        layoutService: ProgressionTreeLayoutService
    ) {
        self.scope = scope
        self.mainStore = mainStore
        self.repository = repository
        self.layoutService = layoutService
    }

    var navigationTitle: String {
        switch scope {
        case .exercise:
            "Progression Tree"
        case .allExercises:
            "All Progressions"
        }
    }

    var treeModel: ProgressionTreeModel {
        let exercises: [Exercise]
        switch scope {
        case .exercise(let exercise):
            exercises = repository.progressionChain(to: exercise.id)
        case .allExercises:
            exercises = repository.exercises
        }
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
