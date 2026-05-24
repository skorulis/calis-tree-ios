// Created by Alex Skorulis on 18/5/2026.

import ASKCoordinator
import Foundation
import UIKit
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
        let availableExercises = exercises.filter { mainStore.hasAvailableEquipment(for: $0) }
        return layoutService.build(from: availableExercises)
    }

    func masteryProgress(for exercise: Exercise) -> ExerciseProgress {
        let fullExercise = repository.fullExercise(for: exercise.id)
            ?? FullExercise(exercise: exercise, progression: [])
        return mainStore.effectiveMasteryProgress(for: fullExercise)
    }
}

// MARK: - Actions

extension ProgressionTreeViewModel {
    func showDetails(exercise: Exercise) {
        coordinator?.push(MainPath.exerciseDetail(exercise))
    }

    func shareImage() -> UIImage? {
        ProgressionTreeImageExporter.render(
            model: treeModel,
            masteryProgress: { [self] exercise in
                masteryProgress(for: exercise)
            }
        )
    }
}
