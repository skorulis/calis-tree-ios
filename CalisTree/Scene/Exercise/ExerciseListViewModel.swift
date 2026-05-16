// Created by Alex Skorulis on 16/5/2026.

import ASKCoordinator
import Foundation
import Knit
import KnitMacros
import Observation

struct ExerciseListItem: Identifiable {
    var id: String { exercise.name }
    let exercise: Exercise
    let masteryProgress: Int
}

@MainActor
@Observable
final class ExerciseListViewModel: CoordinatorViewModel {
    private let mainStore: MainStore
    private let repository: ExerciseRepository
    
    weak var coordinator: Coordinator?
    

    @Resolvable<Resolver>
    init(mainStore: MainStore, repository: ExerciseRepository) {
        self.mainStore = mainStore
        self.repository = repository
    }

    var items: [ExerciseListItem] {
        repository.exercises.map { exercise in
            ExerciseListItem(
                exercise: exercise,
                masteryProgress: mainStore.masteryProgress(for: exercise.name)
            )
        }
    }
}

// MARK: - Actions

extension ExerciseListViewModel {
    func showDetails(exercise: Exercise) {
        coordinator?.push(MainPath.exerciseDetail(exercise))
    }
}
